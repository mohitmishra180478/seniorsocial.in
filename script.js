const menuToggle = document.querySelector('.menu-toggle');
const navLinks = document.querySelector('.nav-links');
const year = document.querySelector('#year');
const joinForm = document.querySelector('#joinForm');

if (year) {
  year.textContent = new Date().getFullYear();
}

if (menuToggle && navLinks) {
  menuToggle.addEventListener('click', () => {
    navLinks.classList.toggle('open');
  });

  document.querySelectorAll('.nav-links a').forEach((link) => {
    link.addEventListener('click', () => navLinks.classList.remove('open'));
  });
}

if (joinForm) {
  joinForm.addEventListener('submit', (event) => {
    event.preventDefault();

    const formData = new FormData(joinForm);
    const details = [
      'New Senior Social India enquiry',
      '',
      `Full name: ${formData.get('Full name') || ''}`,
      `Age: ${formData.get('Age') || ''}`,
      `City: ${formData.get('City') || ''}`,
      `Mobile number: ${formData.get('Mobile number') || ''}`,
      `Email: ${formData.get('Email') || ''}`,
      `Interests: ${formData.get('Interests') || ''}`,
      `Looking for: ${formData.get('Looking for') || ''}`,
      `Consent: ${formData.get('Consent') ? 'Yes' : 'No'}`,
      '',
      'Please contact this person after review/verification.'
    ].join('\n');

    const subject = encodeURIComponent('Senior Social India - New Join Request');
    const body = encodeURIComponent(details);

    window.location.href = `mailto:info@seniorsocial.in?subject=${subject}&body=${body}`;
  });
}
