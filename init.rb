require 'redmine'

Redmine::Plugin.register :chiliproject_las_weekend do
  name 'LAS Weekend'
  author 'Eric Davis'
  url "https://projects.littlestreamsoftware.com/"
  author_url 'http://www.littlestreamsoftware.com'
  description 'LAS Weekend'
  version '0.1.0'

  requires_redmine :version_or_higher => '1.0.0'
end
