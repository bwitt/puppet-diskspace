require 'facter'

if Facter.value(:kernel) == 'Linux'
  df      = '/bin/df'
  pattern = '^([/\w\-\.:]+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)%\s+([/\w\-\.:]+)'
  dmatch  = 6
  umatch  = 5
elsif Facter.value(:kernel) == 'AIX'
  df      = '/usr/bin/df'
  pattern = '^(?:map )?([/\w\-\.:\-]+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)%\s+([/\w\-\.:]+)\s+(\d+)\s+(\d+)%\s+([/\w\-\.:\-]+)'
  dmatch  = 9
  umatch  = 5
end

mounts = Facter::Core::Execution.exec(df)
mounts_array = mounts.split("\n")
mounts_array.each do |line|
  m = /#{pattern}/.match(line)
  if m
    fs = m[dmatch].gsub(/^\/$/, 'root')
    fs = fs.gsub(/[\/\.:\-]/, '')
    Facter.add("diskspace_#{fs}") do
      setcode do
        m[umatch].to_i
      end
    end
    Facter.add("diskspacefree_#{fs}") do
      setcode do
        100 - m[umatch].to_i
      end
    end
  end
end
