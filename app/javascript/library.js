function updateLibraryFields(event) {
  const select = document.getElementById('book_choice');
  const isbn = document.getElementById('book_isbn');

  if (select && isbn) {
    isbn.value = select.selectedOptions[0]?.dataset.isbn || '';
  }

  const name = document.getElementById('member_name');
  const id = document.getElementById('member_id');

  if (name && id && event?.target === name) {
    const option = [...document.querySelectorAll('#member_names option')]
      .find((item) => item.value === name.value);

    id.value = option?.dataset.id || '';
  }
}

document.addEventListener('turbo:load', updateLibraryFields);
document.addEventListener('change', updateLibraryFields);
document.addEventListener('input', updateLibraryFields);
let searchTimer;
document.addEventListener('input', (event) => {
  if (!event.target.matches('[data-instant-search]')) return;
  clearTimeout(searchTimer);
  searchTimer = setTimeout(() => event.target.form.requestSubmit(), 300);
});
