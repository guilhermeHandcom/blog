class RenamePasswordToHashedPassword < ActiveRecord::Migration
  def change
  	rename_column :users, :password, :hashed_passowrd
  end
end
