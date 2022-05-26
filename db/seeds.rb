# メインのサンプルユーザーを1人作成する
User.create!(name:  "Takaki Nakamura",
             email: "takaki55730317@gmail.com",
             password:               "password123",
             password_confirmation:  "password123",
            admin: true)

# 追加のユーザーをまとめて生成する
99.times do |n|
  name    = Faker::Name.name
  email   = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end
