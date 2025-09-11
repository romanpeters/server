server {
    listen 443 default_server;
    server_name _;

    ssl_certificate /etc/letsencrypt/live/romanpeters.nl/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/romanpeters.nl/privkey.pem;

    location / {
        # Serve CSS and icons directly if they exist
        try_files $uri $uri/ @fallback;
    }

    location @fallback {
        # Return 404 for everything except CSS and icons
        try_files $uri.html $uri/ =404;
    }
}


server {
    listen 443;
    server_name romanpeters.nl www.romanpeters.nl;

    ssl_certificate /etc/letsencrypt/live/romanpeters.nl/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/romanpeters.nl/privkey.pem;

    root /var/www/html/romanpeters.nl;

    location = / {
        return 301 https://hello.romanpeters.nl/;
    }

    location / {
        try_files $uri $uri.html $uri/ =404;
    }

    error_page 404 /404.html;
    location = /404.html {
        root /var/www/html/romanpeters.nl;
        internal;
    }
}
