require 'test_helper'

describe Ability do
  describe "guest user" do
    let(:user) { nil }
    let(:guest_user_ability) { Ability.new(user) }

    it { guest_user_ability.can?(:manage, [Location, Category]) }
    it { guest_user_ability.can?(:create, Property) }
  end

  describe "corporate user ability" do
    let(:corporate_user) { FactoryGirl.create(:user, current_property_role: Role.corporate) }
    let(:corporate_ability) { Ability.new(corporate_user) }

    it { corporate_ability.cannot?(:index, List).must_equal true }
  end

  describe "gm user ability" do
    let(:gm_user) { FactoryGirl.create(:user, current_property_role: Role.gm) }
    let(:gm_ability) { Ability.new(gm_user) }

    it { gm_ability.can?(:index, List).must_equal true }
    it { gm_ability.can?(:manage_restricted_attributes, User).must_equal true }
  end

  describe "manager user ability" do
    let(:manager_user) { FactoryGirl.create(:user, current_property_role: Role.manager) }
    let(:manager_ability) { Ability.new(manager_user) }

    it { manager_ability.can?(:manage_restricted_attributes, User).must_equal false }
  end

  describe "admin user ability" do
    let(:admin_user) { FactoryGirl.create(:user, current_property_role: Role.admin) }
    let(:admin_ability) { Ability.new(admin_user) }

    it { assert(admin_ability.can?(:manage, Property)) }
    it { assert(admin_ability.can?(:manage, User)) }
  end

  describe "all logged in users" do
    let(:user) { FactoryGirl.create(:user) }
    let(:another_user) { FactoryGirl.create(:user) }
    let(:ability) { Ability.new(user) }

    it { assert(ability.can?(:update, User.new(id: user.id))) }
    it { assert(ability.can?(:manage, Mention.new(user_id: user.id))) }
    it { assert(ability.can?(:manage, Chat.new(user_id: user.id))) }
    it { assert(ability.cannot?(:manage, Mention.new(user_id: another_user.id))) }
    it { assert(ability.can?(:create, Acknowledgement.new(user_id: user.id))) }
    it { assert(ability.can?(:read, Acknowledgement.new(target_user_id: user.id))) }
    it { assert(ability.can?(:read, Acknowledgement.new(user_id: user.id))) }
    it { assert(ability.can?(:received, Acknowledgement.new(target_user_id: user.id))) }
    it { assert(ability.can?(:sent, Acknowledgement.new(user_id: user.id))) }
    it { assert(ability.can?(:check, Acknowledgement.new(target_user_id: user.id))) }
    it { assert(ability.can?(:manage, Maintenance::WorkOrder.new(opened_by_user_id: user.id))) }
    it { assert(ability.can?(:read, Maintenance::ChecklistItem)) }
    it { assert(ability.can?(:checklist_items, Maintenance::PublicArea)) }
    it { assert(ability.can?(:read, User.new(id: user.id))) }
  end

end
