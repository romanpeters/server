perl_set $today 'sub {
    use POSIX qw(strftime);
    return strftime "%m-%d", localtime;
}';

server {
    listen 443 ssl;
    server_name api.romanpeters.nl;

    ssl_certificate /etc/letsencrypt/live/romanpeters.nl/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/romanpeters.nl/privkey.pem;

    charset utf-8;

    root /var/www/html/api.romanpeters.nl;

    location / {
        try_files $uri $uri.html $uri/ =404;
        error_page 404 /404.html;
    }

    location = /daily/today {
        default_type text/plain;
        alias /var/www/html/api.romanpeters.nl/daily/$today.txt;
    }
    location /daily/ {
        default_type text/plain;
        try_files $uri.txt =404;
    }

}
