class CreateJoinTableBlogsQuestions < ActiveRecord::Migration[8.0]
  def change
    create_join_table :blogs, :questions do |t|
      # t.index [:blog_id, :question_id]
      # t.index [:question_id, :blog_id]
    end
  end
end
