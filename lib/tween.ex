defmodule Vizi.Tween do
  defstruct values: %{}, length: 0, step: 0, easing: nil, next: nil, mode: :once

  @type t :: %Vizi.Tween{
    values: values | proc_values,
    length: integer,
    step: integer,
    easing: function,
    next: t,
    mode: mode
  }

  @type from :: number
  @type delta :: number
  @type length :: integer
  @type step :: integer

  @type mode :: :once | :loop | :pingpong

  @type key :: :x | :y | :width | :height | :alpha | :rotate | :skew_x | :skew_y | :scale_x | :scale_y | {:param, atom}
  @type value :: number | {:add, number} | {:sub, number}
  @type values :: %{optional(key) => value}
  @type proc_values :: [{key, {from, delta}}]

  @type easing :: :lin |
                  :quad_in | :quad_out | :quad_inout |
                  :cubic_in | :cubic_out | :cubic_inout |
                  :quart_in | :quart_out | :quart_inout |
                  :quint_in | :quint_out | :quint_inout |
                  :sin_in | :sin_out | :sin_inout |
                  :exp_in | :exp_out | :exp_inout |
                  :circ_in | :circ_out | :circ_inout |
                  (from, delta, length, step -> number)

  @type option :: {:in, length} | {:use, easing} | {:mode, mode}
  @type options :: [option]

  @allowed_attributes [
    :x, :y,
    :width, :height,
    :alpha, :rotate,
    :skew_x, :skew_y,
    :scale_x, :scale_y
  ]

  # Public API

  @spec new(t, values, options) :: t
  def new(prev \\ nil, values, opts) do
    length = Keyword.fetch!(opts, :in)
    mode = Keyword.get(opts, :mode, :once)
    easing = get_easing_fun(Keyword.get(opts, :use, :lin))
    tween = %Vizi.Tween{values: values, length: length, easing: easing, mode: mode}
    if is_nil(prev) do
      tween
    else
      set_next(prev, tween)
    end
  end

  @spec pause(t, length) :: t
  def pause(prev \\ nil, length) do
    tween = %Vizi.Tween{length: length}
    if is_nil(prev) do
      tween
    else
      set_next(prev, tween)
    end
  end

  @spec into(t, Vizi.Node.t) :: Vizi.Node.t
  def into(tween, node) do
    tween = set_values(tween, node)
    %Vizi.Node{node|tweens: [tween | node.tweens]}
  end

  @spec step(Vizi.Node.t) :: Vizi.Node.t
  def step(%Vizi.Node{tweens: tweens} = node) do
    Enum.reduce(tweens, %Vizi.Node{node|tweens: []}, fn tween, acc ->
      case do_step(tween) do
        :done ->
          acc
        {values, tween} ->
          handle_result(values, tween, acc)
      end
    end)
  end

  @frame_rate_error_msg "can not query frame rate. perhaps this function was called outside a Vizi.View process"

  @spec sec(number) :: length
  def sec(x) do
    case Process.get(:vz_frame_rate) do
      nil ->
        raise @frame_rate_error_msg
      frame_rate ->
        round(x * frame_rate)
    end
  end

  @spec msec(number) :: length
  def msec(x) do
    case Process.get(:vz_frame_rate) do
      nil ->
        raise @frame_rate_error_msg
      frame_rate ->
        round(x / 1000 * frame_rate)
    end
  end

  @spec min(number) :: length
  def min(x) do
    case Process.get(:vz_frame_rate) do
      nil ->
        raise @frame_rate_error_msg
      frame_rate ->
        round(x * 60 * frame_rate)
    end
  end

  defmacro __using__(_) do
    quote do
      alias Vizi.Tween
      import Vizi.Tween, only: [sec: 1, msec: 1, min: 1]
    end
  end

  # Internal functions

  defp set_values(%Vizi.Tween{values: values, next: next} = tween, node) do
    values = values
    |> Enum.map(fn
      {key, {:add, x}} ->
        from = get_value(key, node)
        {key, {from, x}}
      {key, {:sub, x}} ->
        from = get_value(key, node)
        {key, {from, -x}}
      {key, to} ->
        from = get_value(key, node)
        {key, {from, to - from}}
    end)

    %Vizi.Tween{tween|values: values, next: set_values(next, node)}
  end
  defp set_values(nil, _node), do: nil

  defp handle_result(values, tween, node) do
    node = Enum.reduce(values, node, fn
      {{:param, pkey}, value}, acc ->
        %Vizi.Node{acc|params: Map.put(acc.params, pkey, value)}
      {attr, value}, acc ->
        Map.put(acc, attr, value)
    end)
    %Vizi.Node{node|tweens: [tween | node.tweens]}
  end

  defp do_step(%Vizi.Tween{values: values, length: length, step: step, easing: fun, next: next, mode: mode} = tween) do
    step = step + 1
    if step > length do
      case mode do
        :once ->
          do_step(next)
        :loop ->
          do_step(%Vizi.Tween{tween|step: 0})
        :pingpong ->
          do_step(%Vizi.Tween{tween|values: pingpong_values(values), step: 0})
      end
    else
      values = for {key, {from, delta}} <- values, into: %{} do
        {key, fun.(from, delta, length, step)}
      end
      {values, %Vizi.Tween{tween| step: step}}
    end
  end
  defp do_step(nil), do: :done

  defp pingpong_values(values) do
    for {key, {from, delta}} <- values do
      {key, {from + delta, -delta}}
    end
  end

  defp get_value({:param, pkey}, node) do
    case Map.fetch(node.params, pkey) do
      {:ok, value} ->
        value
      :error ->
        raise ArgumentError,
          message: "param key '#{inspect pkey}' does not exist for node\r\n#{inspect node}"
    end
  end
  defp get_value(attr, node)
  when attr in @allowed_attributes do
    Map.get(node, attr)
  end
  defp get_value(attr, node) do
    raise ArgumentError,
      message: "invalid attribute '#{inspect attr}' for node\r\n#{inspect node}"
  end

  #tween(%{{:param, :test} => 5.0}, in: sec(5), use: :exp_in)

  defp set_next(%Vizi.Tween{next: nil} = prev, tween) do
    %Vizi.Tween{prev|next: tween}
  end
  defp set_next(%Vizi.Tween{next: next} = prev, tween) do
    %Vizi.Tween{prev|next: set_next(next, tween)}
  end

  defp get_easing_fun(:lin),         do: &easing_lin/4
  defp get_easing_fun(:quad_in),     do: &easing_quad_in/4
  defp get_easing_fun(:quad_out),    do: &easing_quad_out/4
  defp get_easing_fun(:quad_inout),  do: &easing_quad_inout/4
  defp get_easing_fun(:cubic_in),    do: &easing_cubic_in/4
  defp get_easing_fun(:cubic_out),   do: &easing_cubic_out/4
  defp get_easing_fun(:cubic_inout), do: &easing_cubic_inout/4
  defp get_easing_fun(:quart_in),    do: &easing_quart_in/4
  defp get_easing_fun(:quart_out),   do: &easing_quart_out/4
  defp get_easing_fun(:quart_inout), do: &easing_quart_inout/4
  defp get_easing_fun(:quint_in),    do: &easing_quint_in/4
  defp get_easing_fun(:quint_out),   do: &easing_quint_out/4
  defp get_easing_fun(:quint_inout), do: &easing_quint_inout/4
  defp get_easing_fun(:sin_in),      do: &easing_sin_in/4
  defp get_easing_fun(:sin_out),     do: &easing_sin_out/4
  defp get_easing_fun(:sin_inout),   do: &easing_sin_inout/4
  defp get_easing_fun(:exp_in),      do: &easing_exp_in/4
  defp get_easing_fun(:exp_out),     do: &easing_exp_out/4
  defp get_easing_fun(:exp_inout),   do: &easing_exp_inout/4
  defp get_easing_fun(:circ_in),     do: &easing_circ_in/4
  defp get_easing_fun(:circ_out),    do: &easing_circ_out/4
  defp get_easing_fun(:circ_inout),  do: &easing_circ_inout/4
  defp get_easing_fun(fun) when is_function(fun), do: fun
  defp get_easing_fun(nil), do: nil
  defp get_easing_fun(badarg), do: raise ArgumentError, message: "invalid easing function: #{inspect badarg}"


  defp easing_lin(from, delta, length, step) do
    delta * (step / length) + from
  end

  defp easing_quad_in(from, delta, length, step) do
    step = step / length
    delta * step * step + from
  end

  defp easing_quad_out(from, delta, length, step) do
    step = step / length
    -delta * step * (step - 2) + from
  end

  defp easing_quad_inout(from, delta, length, step) do
    step = step / (length / 2)
    if step < 1 do
      delta / 2 * step * step + from
    else
      step = step - 1
      -delta / 2 * (step * (step - 2) - 1) + from
    end
  end

  defp easing_cubic_in(from, delta, length, step) do
    step = step / length
    delta * step * step * step + from
  end

  defp easing_cubic_out(from, delta, length, step) do
    step = step / length - 1
    delta * (step * step * step + 1) + from
  end

  defp easing_cubic_inout(from, delta, length, step) do
    step = step / (length / 2)
    if step < 1 do
      delta / 2 * step * step * step + from
    else
      step = step - 2
      delta / 2 * (step * step * step + 2) + from
    end
  end

  defp easing_quart_in(from, delta, length, step) do
    step = step / length
    delta * step * step * step * step + from
  end

  defp easing_quart_out(from, delta, length, step) do
    step = step / length - 1
    -delta * (step * step * step * step - 1) + from
  end

  defp easing_quart_inout(from, delta, length, step) do
    step = step / (length / 2)
    if step < 1 do
      delta / 2 * step * step * step * step + from
    else
      step = step - 2
      -delta / 2 * (step * step * step * step - 2) + from
    end
  end

  defp easing_quint_in(from, delta, length, step) do
    step = step / length
    delta * step * step * step * step * step + from
  end

  defp easing_quint_out(from, delta, length, step) do
    step = step / length - 1
    delta * (step * step * step * step * step + 1) + from
  end

  defp easing_quint_inout(from, delta, length, step) do
    step = step / (length / 2)
    if step < 1 do
      delta / 2 * step * step * step * step * step + from
    else
      step = step - 2
      delta / 2 * (step * step * step * step * step + 2) + from
    end
  end

  @pi 3.141592653589793
  @half_pi 3.141592653589793 / 2

  defp easing_sin_in(from, delta, length, step) do
    -delta * :math.cos(step / length * @half_pi) + delta + from
  end

  defp easing_sin_out(from, delta, length, step) do
    delta * -:math.sin(step / length * @half_pi) + from
  end

  defp easing_sin_inout(from, delta, length, step) do
    -delta / 2 * (:math.cos(@pi * step / length) - 1) + from
  end

  defp easing_exp_in(from, delta, length, step) do
    delta * :math.pow(2, 10 * (step / length - 1)) + from
  end

  defp easing_exp_out(from, delta, length, step) do
    delta * (-:math.pow(2, -10 * (step / length)) + 1) + from
  end

  defp easing_exp_inout(from, delta, length, step) do
    step = step / (length / 2)
    if step < 1 do
      delta / 2 * :math.pow(2, 10 * (step - 1) ) + from
    else
      step = step - 1
      delta / 2 * (-:math.pow(2, -10 * step) + 2 ) + from
    end
  end

  defp easing_circ_in(from, delta, length, step) do
    step = step / length
    -delta * (:math.sqrt(1 - step * step) - 1) + from
  end

  defp easing_circ_out(from, delta, length, step) do
    step = step / length - 1
    delta * :math.sqrt(1 - step * step) + from
  end

  defp easing_circ_inout(from, delta, length, step) do
    step = step / (length / 2)
    if step < 1 do
      -delta / 2 * (:math.sqrt(1 - step * step) - 1) + from
    else
      step = step - 2
      delta / 2 * (:math.sqrt(1 - step * step) + 1) + from
    end
  end
end