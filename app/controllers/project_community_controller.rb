# encoding: utf-8
#--
#   Copyright (C) 2013 Gitorious AS
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

class ProjectCommunityController < ApplicationController
  renders_in_site_specific_context
  layout "ui3"

  def index
    project = authorize_access_to(Project.find_by_slug!(params[:project_id]))

    render(:action => :index, :locals => {
        :project => ProjectPresenter.new(project),
        :atom_auto_discovery_url => project_path(project, :format => :atom),
        :atom_auto_discovery_title => "#{project.title} ATOM feed",
        :group_clones => filter(project.recently_updated_group_repository_clones),
        :user_clones => filter(project.recently_updated_user_repository_clones)
      })
  end
end
