class Fixture

  def self.call(name, format="xml", path=nil)
    group = caller.first.to_s.match(/(?<path>.+)\/(?<spec>[a-z_]+)_spec/)
    file_path = "#{group[:path]}/fixtures/#{name.to_s}.#{format}"
    File.read(file_path)
  end

end