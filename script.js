// DOM Elements
const openingScreen = document.getElementById('opening-screen');
const mainInvitation = document.getElementById('main-invitation');
const openInvitationBtn = document.getElementById('open-invitation');
const musicToggle = document.getElementById('music-toggle');
const musicStatus = document.getElementById('music-status');
const backgroundMusic = document.getElementById('background-music');
const commentForm = document.getElementById('comment-form');

// Gallery Variables
const gallerySlides = document.querySelectorAll('.gallery-slide');
const galleryDots = document.querySelectorAll('.dot');
const galleryPrev = document.querySelector('.gallery-prev');
const galleryNext = document.querySelector('.gallery-next');
let currentSlide = 0;

// Countdown Variables
const daysElement = document.getElementById('days');
const hoursElement = document.getElementById('hours');
const minutesElement = document.getElementById('minutes');
const secondsElement = document.getElementById('seconds');

// Wedding date
const weddingDate = new Date('April 12, 2026 09:00:00').getTime();


// =======================
// INITIALIZE WEBSITE
// =======================

document.addEventListener('DOMContentLoaded', function() {

    initGallery();

    updateCountdown();
    setInterval(updateCountdown, 1000);

    document.body.addEventListener('click', initAudio, { once: true });

    initFloatingNav();

});


// =======================
// OPEN INVITATION
// =======================

openInvitationBtn.addEventListener('click', function() {

    openingScreen.classList.remove('active');
    mainInvitation.classList.add('active');

    if (backgroundMusic.paused) {
        backgroundMusic.play().then(() => {
            musicStatus.textContent = 'Musik: ON';
        }).catch(() => {
            musicStatus.textContent = 'Musik: Klik untuk putar';
        });
    }

    window.scrollTo({ top: 0, behavior: 'smooth' });

});


// =======================
// MUSIC CONTROL
// =======================

musicToggle.addEventListener('click', function() {

    if (backgroundMusic.paused) {

        backgroundMusic.play();
        musicStatus.textContent = 'Musik: ON';

    } else {

        backgroundMusic.pause();
        musicStatus.textContent = 'Musik: OFF';

    }

});


function initAudio() {

    backgroundMusic.volume = 0.5;

}


// =======================
// GALLERY
// =======================

function initGallery() {

    showSlide(currentSlide);

    galleryNext.addEventListener('click', function() {

        currentSlide = (currentSlide + 1) % gallerySlides.length;
        showSlide(currentSlide);

    });

    galleryPrev.addEventListener('click', function() {

        currentSlide = (currentSlide - 1 + gallerySlides.length) % gallerySlides.length;
        showSlide(currentSlide);

    });

    galleryDots.forEach((dot, index) => {

        dot.addEventListener('click', function() {

            currentSlide = index;
            showSlide(currentSlide);

        });

    });

    setInterval(function() {

        currentSlide = (currentSlide + 1) % gallerySlides.length;
        showSlide(currentSlide);

    }, 5000);

}


function showSlide(index) {

    gallerySlides.forEach(slide => slide.classList.remove('active'));
    galleryDots.forEach(dot => dot.classList.remove('active'));

    gallerySlides[index].classList.add('active');
    galleryDots[index].classList.add('active');

}


// =======================
// COUNTDOWN
// =======================

function updateCountdown() {

    const now = new Date().getTime();
    const distance = weddingDate - now;

    if (distance < 0) {

        daysElement.textContent = '00';
        hoursElement.textContent = '00';
        minutesElement.textContent = '00';
        secondsElement.textContent = '00';

        return;

    }

    const days = Math.floor(distance / (1000 * 60 * 60 * 24));
    const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((distance % (1000 * 60)) / 1000);

    daysElement.textContent = days.toString().padStart(2, '0');
    hoursElement.textContent = hours.toString().padStart(2, '0');
    minutesElement.textContent = minutes.toString().padStart(2, '0');
    secondsElement.textContent = seconds.toString().padStart(2, '0');

}


// =======================
// COMMENT FORM (FORMSPREE)
// =======================

if (commentForm) {

commentForm.addEventListener('submit', function() {

    const name = document.getElementById('comment-name').value.trim();
    const message = document.getElementById('comment-message').value.trim();

    if (!name || !message) {

        alert("Harap isi nama dan ucapan terlebih dahulu.");
        return false;

    }

    setTimeout(() => {

        showNotification("Ucapan berhasil dikirim. Terima kasih atas doanya!");

    }, 500);

});

}


// =======================
// NOTIFICATION
// =======================

function showNotification(message) {

    const notif = document.createElement('div');
    notif.textContent = message;

    notif.style.cssText = `
        position: fixed;
        top:20px;
        left:50%;
        transform:translateX(-50%);
        background:#d4af37;
        color:white;
        padding:15px 30px;
        border-radius:50px;
        z-index:9999;
        font-weight:500;
    `;

    document.body.appendChild(notif);

    setTimeout(() => {

        notif.remove();

    },3000);

}


// =======================
// FLOATING NAV
// =======================

function initFloatingNav() {

    const navItems = document.querySelectorAll('.nav-item');

    navItems.forEach(item => {

        item.addEventListener('click', function(e) {

            e.preventDefault();

            const targetId = this.getAttribute('href').substring(1);
            const target = document.querySelector(`.${targetId}-section`);

            if (target) {

                window.scrollTo({
                    top: target.offsetTop - 20,
                    behavior: 'smooth'
                });

            }

        });

    });

}