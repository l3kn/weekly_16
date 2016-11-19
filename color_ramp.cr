class ColorRamp
  property steps : Array(Tuple(Color, Float64))

  def initialize(steps)
    # Make sure all steps have valid values
    steps.each do |c, v|
      if v < 0.0 || v > 1.0
        raise "Invalid value ColorRamp step: #{v} (must be in 0..1)"
      end
    end

    # TODO: make sure there are at least two steps
    # one with value 0.0 and one with value 1.0
    @steps = steps.sort_by { |e| e[1] }
  end

  def get(value)
    if value <= 0.0
      steps[0][0]
    elsif value >= 1.0
      steps[-1][0]
    else
      c0, v0 = steps[0]
      c1, v1 = steps[0]

      steps[1..-1].each do |c, v|
        c0 = c1
        v0 = v1
        c1 = c
        v1 = v

        break if v >= value
      end

      t = (value - v0) / (v1 - v0)
      mix(c1, c0, t)
    end
  end
end

class HexColorRamp < ColorRamp
  def initialize(steps : Array(Tuple(String, Float64)))
    super(steps.map { |hex, v| {Color.from_hex(hex), v} })
  end
end


