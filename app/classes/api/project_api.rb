class API
  # API for Project
  class ProjectAPI < ModelAPI
    self.model = Project

    self.high_detail_page_length = 100
    self.low_detail_page_length  = 1000
    self.put_page_length         = 1000
    self.delete_page_length      = 1000

    self.high_detail_includes = [
      :comments,
      :user
    ]

    def query_params
      {
        where:             sql_id_condition,
        created_at:        parse_range(:time, :created_at),
        updated_at:        parse_range(:time, :updated_at),
        users:             parse_array(:user, :user),
        has_images:        parse(:boolean, :has_images, limit: true),
        has_observations:  parse(:boolean, :has_observations, limit: true),
        has_species_lists: parse(:boolean, :has_species_lists, limit: true),
        has_comments:      parse(:boolean, :has_comments, limit: true),
        has_notes:         parse(:boolean, :has_notes),
        title_has:         parse(:string, :title_has),
        notes_has:         parse(:string, :notes_has),
        comments_has:      parse(:string, :comments_has)
      }
    end

    def create_params
      @admins  = parse_array(:user, :admins, default: [user])
      @members = parse_array(:user, :members, default: [user])
      {
        title:   parse(:string, :title, limit: 100),
        summary: parse(:string, :summary)
      }
    end

    def validate_create_params!(params)
      @title = params[:title].to_s
      @title2 = @title + ".admin"
      raise MissingParameter.new(:title) if @title.blank?
      raise ProjectTaken.new(@title)     if Project.find_by_title(@title)
      raise UserGroupTaken.new(@title)   if UserGroup.find_by_name(@title)
      raise UserGroupTaken.new(@title2)  if UserGroup.find_by_name(@title2)
    end

    def before_create
      member_group = UserGroup.new(
        name:  @title,
        users: @members
      )
      admin_group = UserGroup.new(
        name:  @title2,
        users: @admins
      )
      member_group.save || raise(CreateFailed.new(member_group))
      admin_group.save  || raise(CreateFailed.new(admin_group))
      params[:user_group]  = member_group
      params[:admin_group] = admin_group
    end

    def build_setter
      params = parse_setting_parameters
      lambda do |proj|
        raise MustBeAdmin.new(proj) unless proj.is_admin?(@user)
        proj.update!(params) unless params.empty?
        update_admin_group(proj)
        update_user_group(proj)
        update_images(proj)
        update_observations(proj)
        update_species_lists(proj)
      end
    end

    def update_params
      {
        title:   parse(:string, :set_title, limit: 100),
        summary: parse(:string, :set_summary)
      }
    end

    def delete
      raise NoMethodForAction.new("DELETE", action)
    end

    ############################################################################

    private

    def update_admin_group(proj)
      proj.admin_group.users.push(@add_admins)      if @add_admins.any?
      proj.admin_group.users.delete(@remove_admins) if @remove_admins.any?
    end

    def update_user_group(proj)
      proj.user_group.users.push(@add_members)      if @add_members.any?
      proj.user_group.users.delete(@remove_members) if @remove_members.any?
    end

    def update_images(proj)
      proj.add_images(@add_images)       if @add_imgs.any?
      proj.remove_images(@remove_images) if @remove_imgs.any?
    end

    def update_observations(proj)
      proj.add_observations(@add_obs)       if @add_obs.any?
      proj.remove_observations(@remove_obs) if @remove_obs.any?
    end

    def update_species_lists(proj)
      proj.add_species_lists(@add_spls)       if @add_spls.any?
      proj.remove_species_lists(@remove_spls) if @remove_spls.any?
    end

    def parse_setting_parameters
      params = update_params
      parse_add_remove_admins
      parse_add_remove_members
      parse_add_remove_images
      parse_add_remove_observations
      parse_add_remove_species_lists
      params.remove_nils!
      make_sure_parameters_not_empty!
      params
    end

    def parse_add_remove_admins
      @add_admins    = parse_array(:user, :add_admins) || []
      @remove_admins = parse_array(:user, :remove_admins) || []
    end

    def parse_add_remove_members
      @add_members    = parse_array(:user, :add_members) || []
      @remove_members = parse_array(:user, :remove_members) || []
    end

    def parse_add_remove_images
      @add_imgs    = parse_array(:image, :add_images) || []
      @remove_imgs = parse_array(:image, :remove_images) || []
    end

    def parse_add_remove_observations
      @add_obs    = parse_array(:observation, :add_observations) || []
      @remove_obs = parse_array(:observation, :remove_observations) || []
    end

    def parse_add_remove_species_lists
      @add_spls    = parse_array(:species_list, :add_species_lists) || []
      @remove_spls = parse_array(:species_list, :remove_species_lists) || []
    end

    def make_sure_parameters_not_empty!
      return unless params.empty? && adds_and_removes.empty?
      raise MissingSetParameters.new
    end

    def adds_and_removes
      @add_admins + @remove_admins + @add_members + @remove_members +
        @add_imgs + @remove_imgs + @add_obs + @remove_obs + @add_spls +
        @remove_spls
    end
  end
end
