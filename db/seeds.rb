authors = 3.times.map do |i|
  Author.find_or_create_by!(name: "Автор #{i + 1}") do |a|
    a.biography = "Учебная биография"
  end
end

books = 5.times.map do |i|
  Book.find_or_create_by!(isbn: "978000000001#{i}") do |b|
    b.title = "Книга #{i + 1}"
    b.published_year = 2020 + i
    b.author = authors[i % 3]
  end
end

members = 4.times.map do |i|
  Member.find_or_create_by!(email: "reader#{i + 1}@example.org") do |m|
    m.name = "Читатель #{i + 1}"
    m.phone = "+7000000000#{i}"
  end
end

2.times do |i|
  Borrowing.find_or_create_by!(
    book: books[i],
    member: members[i],
    borrowed_on: Date.new(2026, 11, 1)
  ) do |x|
    x.due_on = Date.new(2026, 11, 15)
  end
end
