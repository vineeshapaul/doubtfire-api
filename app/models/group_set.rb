class GroupSet < ActiveRecord::Base
  belongs_to :unit
  has_many :groups, dependent: :destroy

  validates_associated :groups
  validate :must_be_in_same_tutorial, if: :keep_groups_in_same_class

  #
  # Permissions around group set data
  #
  def self.permissions
    # What can students do with group sets?
    student_role_permissions = [
      :get_groups
    ]
    # What can tutors do with group sets?
    tutor_role_permissions = [
      :get_groups,
      :join_group,
      :create_group
    ]
    # What can convenors do with group sets?
    convenor_role_permissions = [
      :get_groups,
      :join_group,
      :create_group
    ]
    # What can nil users do with group sets?
    nil_role_permissions = [

    ]

    # Return permissions hash
    {
      :convenor => convenor_role_permissions,
      :tutor    => tutor_role_permissions,
      :student  => student_role_permissions,
      :nil      => nil_role_permissions
    }
  end

  def specific_permission_hash(role, perm_hash, other)
    result = perm_hash[role] unless perm_hash.nil?
    if result && role == :student
      if allow_students_to_create_groups
        result << :create_group
      end
      if allow_students_to_manage_groups
        result << :join_group
      end
    end
    result
  end

  def role_for(user)
    unit.role_for(user)
  end

  def must_be_in_same_tutorial
    if keep_groups_in_same_class
      groups.each do | grp |
        if not grp.all_members_in_tutorial?
          errors.add(:groups, "exist where some members are not in the group's tutorial")
        end
      end
    end
  end
end
