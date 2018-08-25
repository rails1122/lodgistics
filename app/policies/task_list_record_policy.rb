class TaskListRecordPolicy < TaskListPolicy
  def show?
    assignable? || reviewable?
  end

  def finish?
    assignable?
  end

  def review?
    reviewable?
  end

  private

  def get_task_list
    @record.task_list
  end
end