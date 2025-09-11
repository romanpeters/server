	proxy_bind $server_addr;
        proxy_set_header Upgrade $http_upgrade;
	proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Scheme $scheme;
        proxy_set_header X-Script-Name /calibre;
