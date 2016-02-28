include InitialTestData::Utilities
include FactoryGirl::Syntax::Methods

store create(:user), :test1
store create(:user), :test2
store create(:user), :test3
