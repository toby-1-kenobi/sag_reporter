desc 'prompt language champions of languages that may need updating'
task :prompt_champions => :environment do
  Language.prompt_champions
end