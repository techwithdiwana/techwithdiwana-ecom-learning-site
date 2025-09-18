async function loadCourses(){
  try{
    const res = await fetch('/api/courses');
    const courses = await res.json();
    const gallery = document.getElementById('course-gallery');
    gallery.innerHTML = '';
    courses.forEach(c => {
      const card = document.createElement('article');
      card.className = 'card';
      card.innerHTML = `
        <img src="${c.image}" alt="${c.title}">
        <h3>${c.title}</h3>
        <p>${c.description}</p>
        <div class="price">₹${c.price}</div>`;
      gallery.appendChild(card);
    });
  }catch(err){console.error('Failed to load courses',err)}
}
document.addEventListener('DOMContentLoaded',loadCourses);