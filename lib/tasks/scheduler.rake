desc 'prompt language champions of languages that may need updating'
task :prompt_champions => :environment do
  Language.prompt_champions
end

desc 'prompt curators of edits that need curating'
task :prompt_curators => :environment do
  Edit.prompt_curators
end

desc 'disable stale user accounts'
task :disable_stale => :environment do
  User.disable_stale_accounts
end