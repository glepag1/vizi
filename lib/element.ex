defmodule Vizi.Element do
  alias Vizi.{Element, Events, NIF}

  defstruct tags: [],
            x: 0.0, y: 0.0,
            width: 0.0, height: 0.0,
            children: [],
            scale_x: 1.0, scale_y: 1.0,
            skew_x: 0.0, skew_y: 0.0,
            rotate: 0.0, alpha: 1.0,
            mod: nil, params: %{},
            initialized: false,
            xform: nil

  @type t :: %Vizi.Element{
    tags: [tag],
    x: number, y: number,
    width: number, height: number,
    children: [t],
    scale_x: number, scale_y: number,
    skew_x: number, skew_y: number,
    rotate: number, alpha: number,
    mod: module | nil, params: params,
    initialized: boolean,
    xform: Vizi.Canvas.Transform.t | nil
  }

  @type tag :: term

  @type params :: %{optional(atom) => term}

  @type updates :: [{atom, (term -> term)}]

  @typedoc "Option values used by `create/3`"
  @type option :: {:tags, [tag]} |
                  {:x, number} |
                  {:y, number} |
                  {:width, number} |
                  {:height, number} |
                  {:children, [t]} |
                  {:scale_x, number} |
                  {:scale_y, number} |
                  {:skew_x, number} |
                  {:skew_y, number} |
                  {:rotate, number} |
                  {:alpha, number} |
                  {:x, number} |
                  {:mod, module} |
                  {:params, params}



  @typedoc "Options used by `create/3`"
  @type options :: [option]

  @doc """
  Invoked once before receiving any events, or the `draw/4` function is called.

  This function can be used for setting up fonts, images and other resources that are needed for drawing.
  """
  @callback init(el :: Vizi.Element.t, ctx :: Vizi.View.context) ::
  new_el when new_el: Vizi.Element.t

  @doc """
  Invoked after `Vizi.View.redraw/1` has been called when `redraw_mode` is `:manual`, or automatically when `redraw_mode` is `:interval`.


  """
  @callback draw(ctx :: Vizi.View.context, width :: number, height :: number, params :: params) :: term

  @callback handle_event(el :: Vizi.Element.t, event :: struct) ::
  :cont | :done |
  {:done, new_el} |
  {:cont, new_el} when new_el: Vizi.Element.t

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Vizi.Element

      @doc false
      def init(el, _ctx) do
        {:ok, el}
      end

      @doc false
      def update(el, _ctx) do
        {:ok, el}
      end

      @doc false
      def draw(_params, _width, _height, _ctx) do
        :ok
      end

      @doc false
      def handle_event(_el, _event) do
        :cont
      end

      defoverridable [init: 2, update: 2, draw: 4, handle_event: 2]
    end
  end


  # Public interface

  @spec create(mod :: module, params :: params, opts :: options) :: t
  def create(mod, params, opts \\ []) do
    %Element{
      tags: Keyword.get(opts, :tags, []),
      x: Keyword.get(opts, :x, 0.0),
      y: Keyword.get(opts, :y, 0.0),
      width: Keyword.get(opts, :width, 0.0),
      height: Keyword.get(opts, :height, 0.0),
      children: Keyword.get(opts, :children, []),
      scale_x: Keyword.get(opts, :scale_x, 1.0),
      scale_y: Keyword.get(opts, :scale_y, 1.0),
      skew_x: Keyword.get(opts, :skew_x, 0.0),
      skew_y: Keyword.get(opts, :skew_y, 0.0),
      rotate: Keyword.get(opts, :rotate, 0.0),
      alpha: Keyword.get(opts, :alpha, 1.0),
      mod: mod,
      params: params
    }
  end

  @spec put_front(parent :: t, el :: t) :: t
  def put_front(%Element{children: children} = parent, el) do
    children = List.delete(children, el)
    %Element{parent|children: children ++ [el]}
  end

  @spec put_back(parent :: t, el :: t) :: t
  def put_back(%Element{children: children} = parent, el) do
    children = List.delete(children, el)
    %Element{parent|children: [el | children]}
  end

  @spec put_before(parent :: t, member :: t, el :: t) :: t
  def put_before(%Element{} = parent, member, el) do
    put_ba(parent, :before, member, el)
  end

  @spec put_after(parent :: t, member :: t, el :: t) :: t
  def put_after(%Element{} = parent, member, el) do
    put_ba(parent, :after, member, el)
  end

  defp put_ba(parent, op, member, el) do
    put_fun = case op do
      :before -> fn acc -> [el, member | acc] end
      :after  -> fn acc -> [member, el | acc] end
    end

    {_del, put, children} = Enum.reduce(parent.children, {false, false, []}, fn x, {del, put, acc} ->
      cond do
        not put and x == member -> {del, true, put_fun.(acc)}
        not del and x == el     -> {true, put, acc}
        true                    -> {del, put, [x | acc]}
      end
    end)

    if put do
      %Element{parent|children: Enum.reverse(children)}
    else
      parent
    end
  end

  @spec remove(parent :: t, el :: t) :: t
  def remove(%Element{children: children} = parent, el) do
    children = Enum.filter(children, &(&1 != el))
    %Element{parent|children: children}
  end

  @spec all(parent :: t, tags :: tag | [tag]) :: [t]
  def all(%Element{children: children}, tags) do
    tags = List.wrap(tags)
    Enum.filter(children, fn x ->
      Enum.all?(tags, &(&1 in x.tags))
    end)
  end

  @spec any(parent :: t, tags :: tag | [tag]) :: [t]
  def any(%Element{children: children}, tags) do
    tags = List.wrap(tags)
    Enum.filter(children, fn x ->
      Enum.any?(tags, &(&1 in x.tags))
    end)
  end

  @spec one(parent :: t, tags :: tag | [tag]) :: {:ok, t} | nil | :error
  def one(%Element{} = parent, tags) do
    case all(parent, tags) do
      [el] -> {:ok, el}
      []   -> nil
      _    -> :error
    end
  end

  @spec update_all(parent :: t, tags :: tag | [tag], function) :: [t]
  def update_all(%Element{children: children} = parent, tags, fun) do
    tags = List.wrap(tags)
    children = for x <- children do
      if Enum.all?(tags, &(&1 in x.tags)) do
        fun.(x)
      else
        x
      end
    end
    %Element{parent|children: children}
  end

  @spec update_any(parent :: t, tags :: tag | [tag,], function) :: [t]
  def update_any(%Element{children: children} = parent, tags, fun) do
    tags = List.wrap(tags)
    children = for x <- children do
      if Enum.any?(tags, &(&1 in x.tags)) do
        fun.(x)
      end
    end
    %Element{parent|children: children}
  end

  @spec put_param(el :: t, key :: atom, value :: term) :: t
  def put_param(%Element{params: params} = el, key, value) do
    %Element{el|params: Map.put(params, key, value)}
  end

  @spec put_params(el :: t, params :: params) :: t
  def put_params(%Element{} = el, params) do
    %Element{el|params: Map.merge(el.params, params)}
  end

  @spec update_param(el :: t, key :: atom, initial :: term, fun :: (term -> term)) :: t
  def update_param(%Element{params: params} = el, key, initial, fun) do
    %Element{el|params: Map.update(params, key, initial, fun)}
  end

  @spec update_param!(el :: t, key :: atom, fun :: (term -> term)) :: t
  def update_param!(%Element{params: params} = el, key, fun) do
    %Element{el|params: Map.update!(params, key, fun)}
  end

  @spec update_params!(el :: t, updates) :: t
  def update_params!(%Element{params: params} = el, updates) do
    params = Enum.reduce(updates, params, fn {key, fun}, acc ->
      Map.update!(acc, key, fun)
    end)
    %Element{el|params: params}
  end

  @spec update_attributes(el :: t, updates) :: t
  def update_attributes(el, updates) do
    Enum.reduce(updates, el, fn {key, fun}, acc ->
      Map.update!(acc, key, fun)
    end)
  end

  # Internals

  @doc false
  def draw(%Element{mod: mod, children: children, width: width, height: height} = el, ctx) do
    NIF.save(ctx)
    el = maybe_init(el, ctx)
    el = case mod.update(el, ctx) do
      {:ok, el} ->
        el
      bad_return ->
        raise "bad return value from #{inspect el.mod}.update/2: #{inspect bad_return}"
    end

    NIF.setup_element(ctx, el)
    mod.draw(el.params, width, height, ctx)
    children = draw(children, ctx)
    NIF.restore(ctx)
    %Element{el|children: children}
  end
  def draw(els, ctx) when is_list(els) do
    Enum.map(els, &draw(&1, ctx))
  end

  defp maybe_init(%Element{initialized: false} = el, ctx) do
    case el.mod.init(el, ctx) do
      {:ok, el} ->
        %Element{el|xform: NIF.transform_translate(0, 0), initialized: true}
      bad_return ->
        raise "bad return value from #{inspect el.mod}.init/2: #{inspect bad_return}"
    end
  end
  defp maybe_init(el, _ctx), do: el

  @doc false
  def handle_events(%Element{} = el, events, ctx) do

    {el, events} = Enum.reduce(events, {el, []}, &maybe_handle_event/2)
    {children, events} = handle_events(el.children, Enum.reverse(events), ctx)
    {%Element{el | children: children}, events}
  end
  def handle_events(els, events, ctx) when is_list(els) do
    {els, events} = Enum.reduce(els, {[], events}, fn el, {els, evs} ->
      {new_el, new_evs} = handle_events(el, evs, ctx)
      {[new_el | els], new_evs}
    end)
    {Enum.reverse(els), events}
  end

  defp maybe_handle_event(%Events.Custom{} = ev, {el, acc}) do
    handle_event(el, ev, acc)
  end
  defp maybe_handle_event(%{type: type} = ev, {el, acc})
  when type in ~w(button_press button_release key_press key_release motion scroll)a do
    inv_xform = NIF.transform_inverse(el.xform)
    {x, y} = NIF.transform_point(inv_xform, ev.abs_x, ev.abs_y)
    if touches?(el, x, y) do
      handle_event(el, %{ev|x: x, y: y}, acc)
    else
      {el, [ev | acc]}
    end
  end
  defp maybe_handle_event(ev, {el, acc}) do
    {el, [ev | acc]}
  end

  defp handle_event(el, ev, acc) do
    case el.mod.handle_event(el, ev) do
      :cont ->
        {el, [ev | acc]}
      {:done, new_el} ->
        {new_el, acc}
      {:cont, new_el} ->
        {new_el, [ev | acc]}
      :done ->
        {el, acc}
    end
  end

  defp touches?(%Element{width: width, height: height}, x, y) do
    x >= 0 and x <= width and y >= 0 and y <= height
  end
end