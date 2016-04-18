class ActiveRecordMigration < ActiveRecord::ActiveRecordMigration
  def change
    create_table :mage_steps do |t|
      t.belongs_to(:object, polymorphic: true)
      t.string :step

      t.timestamps null: false
    end
  end
end
