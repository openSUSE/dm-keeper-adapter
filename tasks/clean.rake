task :clean do
  `rm -rf *~`
  `rm -rf */*~`
  `rm -rf */*/*~`
  `rm -rf pkg`
  `rm -f Gemfile.lock`
end
