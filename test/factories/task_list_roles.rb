FactoryGirl.define do
  factory :task_list_role do
    property_id { Property.current_id }

    trait :assignable do
      scope_type { TaskListRole.scope_types[:assignable] }
    end

    trait :reviewable do
      scope_type { TaskListRole.scope_types[:reviewable] }
    end

    factory :task_list_role_assignable, traits: [:assignable]
    factory :task_list_role_reviewable, traits: [:reviewable]
  end
end
