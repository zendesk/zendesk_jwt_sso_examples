require "rake"

desc "update bundles"
task :update_bundles do
  tmp = File.join(File.dirname(__FILE__), "tmp")
  out = "iis_ad_asp_jwt"

  FileUtils.rm_rf(tmp)
  FileUtils.mkdir_p(tmp)

  # Classic ASP bundle
  Dir.chdir(tmp) do
    `wget https://github.com/zendesk/classic_asp_jwt/archive/master.zip > /dev/null 2>&1`
    `unzip master`
    `mv classic_asp_jwt-master #{out}`
    `cp ../classic_asp_jwt_with_ad.asp #{out}`
    `zip -r #{out}.zip #{out}`
    `mv #{out}.zip ../bundles/`
  end
end
