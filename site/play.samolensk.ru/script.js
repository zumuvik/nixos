/* ═══════════════════════════════════════════════════════
   🐾 play.samolensk.ru — Interactive Scripts
   Floating hearts, smooth scroll, intersection observer
   ═══════════════════════════════════════════════════════ */

document.addEventListener('DOMContentLoaded', () => {
  initFloatingHearts();
  initNavbar();
  initMobileMenu();
  initScrollAnimations();
  initCopyIP();
  initParallax();
});

/* ── Floating Pixel Hearts ──────────────────────────── */
function initFloatingHearts() {
  const canvas = document.getElementById('hearts-canvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');

  function resize() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  }
  resize();
  window.addEventListener('resize', resize);

  const hearts = [];
  const heartColors = [
    'rgba(236, 72, 153, 0.4)',
    'rgba(168, 85, 247, 0.3)',
    'rgba(249, 168, 212, 0.35)',
    'rgba(196, 181, 253, 0.3)',
    'rgba(192, 132, 252, 0.25)',
  ];

  class Heart {
    constructor() {
      this.reset();
    }

    reset() {
      this.x = Math.random() * canvas.width;
      this.y = canvas.height + 20 + Math.random() * 100;
      this.size = 4 + Math.random() * 10;
      this.speed = 0.3 + Math.random() * 0.8;
      this.opacity = 0.2 + Math.random() * 0.5;
      this.wobbleSpeed = 0.01 + Math.random() * 0.02;
      this.wobbleAmount = 20 + Math.random() * 40;
      this.angle = Math.random() * Math.PI * 2;
      this.color = heartColors[Math.floor(Math.random() * heartColors.length)];
      this.rotation = Math.random() * Math.PI * 2;
      this.rotationSpeed = (Math.random() - 0.5) * 0.02;
    }

    drawPixelHeart(ctx) {
      const s = this.size / 5;
      ctx.save();
      ctx.translate(this.x, this.y);
      ctx.rotate(this.rotation);
      ctx.globalAlpha = this.opacity;

      // Pixel heart pattern (7x6 grid)
      const pattern = [
        [0, 1, 1, 0, 1, 1, 0],
        [1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1],
        [0, 1, 1, 1, 1, 1, 0],
        [0, 0, 1, 1, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 0],
      ];

      const offsetX = -3.5 * s;
      const offsetY = -3 * s;

      ctx.fillStyle = this.color;
      for (let row = 0; row < pattern.length; row++) {
        for (let col = 0; col < pattern[row].length; col++) {
          if (pattern[row][col]) {
            ctx.fillRect(
              offsetX + col * s,
              offsetY + row * s,
              s, s
            );
          }
        }
      }

      ctx.restore();
    }

    update() {
      this.y -= this.speed;
      this.angle += this.wobbleSpeed;
      this.x += Math.sin(this.angle) * 0.5;
      this.rotation += this.rotationSpeed;

      if (this.y < -30) {
        this.reset();
      }
    }
  }

  // Create hearts
  const heartCount = Math.min(25, Math.floor(window.innerWidth / 50));
  for (let i = 0; i < heartCount; i++) {
    const h = new Heart();
    h.y = Math.random() * canvas.height;
    hearts.push(h);
  }

  function animate() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    hearts.forEach(heart => {
      heart.update();
      heart.drawPixelHeart(ctx);
    });
    requestAnimationFrame(animate);
  }

  animate();
}

/* ── Navbar Scroll Effect ───────────────────────────── */
function initNavbar() {
  const navbar = document.querySelector('.navbar');
  if (!navbar) return;

  let ticking = false;
  window.addEventListener('scroll', () => {
    if (!ticking) {
      requestAnimationFrame(() => {
        navbar.classList.toggle('scrolled', window.scrollY > 50);
        ticking = false;
      });
      ticking = true;
    }
  });
}

/* ── Mobile Menu Toggle ─────────────────────────────── */
function initMobileMenu() {
  const toggle = document.getElementById('nav-toggle');
  const links = document.getElementById('nav-links');
  if (!toggle || !links) return;

  toggle.addEventListener('click', () => {
    links.classList.toggle('active');
    toggle.textContent = links.classList.contains('active') ? '✕' : '☰';
  });

  // Close menu on link click
  links.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      links.classList.remove('active');
      toggle.textContent = '☰';
    });
  });
}

/* ── Scroll Animations (Intersection Observer) ──────── */
function initScrollAnimations() {
  const observerOptions = {
    threshold: 0.15,
    rootMargin: '0px 0px -50px 0px',
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry, index) => {
      if (entry.isIntersecting) {
        // Stagger animation for siblings
        const siblings = entry.target.parentElement.querySelectorAll('.plugin-card, .guide-step');
        const idx = Array.from(siblings).indexOf(entry.target);
        const delay = idx * 100;

        setTimeout(() => {
          entry.target.classList.add('visible');
        }, delay);

        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);

  // Observe plugin cards
  document.querySelectorAll('.plugin-card').forEach(card => {
    observer.observe(card);
  });

  // Observe guide steps
  document.querySelectorAll('.guide-step').forEach(step => {
    observer.observe(step);
  });
}

/* ── Copy IP Address ────────────────────────────────── */
function initCopyIP() {
  const copyBoxes = document.querySelectorAll('.ip-copy-box');
  const toast = document.getElementById('copy-toast');

  copyBoxes.forEach(box => {
    box.addEventListener('click', async () => {
      const ip = 'play.samolensk.ru';
      try {
        await navigator.clipboard.writeText(ip);
      } catch {
        // Fallback for non-HTTPS
        const ta = document.createElement('textarea');
        ta.value = ip;
        ta.style.position = 'fixed';
        ta.style.opacity = '0';
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
      }

      if (toast) {
        toast.classList.add('show');
        setTimeout(() => toast.classList.remove('show'), 2000);
      }
    });
  });
}

/* ── Parallax Effect on Hero ────────────────────────── */
function initParallax() {
  const heroBg = document.querySelector('.hero-bg img');
  if (!heroBg) return;

  let ticking = false;
  window.addEventListener('scroll', () => {
    if (!ticking) {
      requestAnimationFrame(() => {
        const scrolled = window.scrollY;
        if (scrolled < window.innerHeight) {
          heroBg.style.transform = `translateY(${scrolled * 0.3}px) scale(1.1)`;
        }
        ticking = false;
      });
      ticking = true;
    }
  });
}
