#!/usr/bin/python3 -u

import asyncio
import asyncpg
import tornado.ioloop
import tornado.web
import os
import ssl

async def start_app():
	global ssl_ctx
	import crashreporting
	app = tornado.web.Application([
		(r"/upload", crashreporting.CrashReporting),
		(r"/", IndexPage),
	])
	app.pg_pool = await asyncpg.create_pool(os.environ['POSTGRES_CONNECTION_URL'], min_size=1, max_size=5)
	if os.environ.get('SERVER_MODE') == 'test':
		app.listen(8080)
	else:
		port = os.environ.get('LISTEN_PORT', 443)
		ssl_ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
		load_app_certificate()
		app.listen(port, ssl_options=ssl_ctx)

def load_app_certificate():
	global ssl_ctx
	print("Loading Certificate")
	ssl_ctx.load_cert_chain(os.environ['SSL_CERT_FILE'], os.environ['SSL_KEY_FILE'])
	
	# Reload the certificate once a day
	# certbot automatically renews certificates
	asyncio.get_running_loop().call_later(86400, load_app_certificate)
	
class IndexPage(tornado.web.RequestHandler):
	async def get(self):
		self.render("index.html")

if __name__ == "__main__":
	loop = asyncio.new_event_loop()
	asyncio.set_event_loop(loop)
	loop.run_until_complete(start_app())
	loop.run_forever()