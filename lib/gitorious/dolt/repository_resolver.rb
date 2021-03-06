# encoding: utf-8
#--
#   Copyright (C) 2012-2013 Gitorious AS
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
require "libdolt"
require "presenters/repository_presenter"

module Gitorious
  module Dolt
    class Repository < ::Dolt::Git::Repository
      attr_reader :meta

      def initialize(repository)
        @meta = RepositoryPresenter.new(repository)
        super(repository.full_repository_path)
      end

      def id; @meta.id; end
      def path_segment; @meta.path_segment; end
      def real_gitdir; @meta.real_gitdir; end
      def full_repository_path; @meta.full_repository_path; end
      def head_candidate_name; @meta.head_candidate_name; end
      def disk_usage; @meta.disk_usage; end
    end

    class RepositoryResolver
      def initialize(scope = ::Repository)
        @scope = scope
      end

      def resolve(repo)
        repository = @scope.find_by_path(repo)
        raise ActiveRecord::RecordNotFound.new if repository.nil?
        Gitorious::Dolt::Repository.new(repository)
      end
    end
  end
end
