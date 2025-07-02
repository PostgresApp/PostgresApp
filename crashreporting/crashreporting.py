import tornado.websocket
import json
import os
import asyncio
import asyncpg

class CrashReporting(tornado.web.RequestHandler):

	async def post(self):
		
		# crash reports should always be valid utf-8
		# .crash files are text based
		# .ips are json-based
		crash_report = self.request.body.decode()
		
		# we can extract Postgres.app version from the user agent
		user_agent = self.request.headers.get("User-Agent")
		
		await self.application.pg_pool.execute(
			"INSERT INTO crash_reports(report, user_agent) VALUES($1, $2);",
			crash_report,
			user_agent
		)
		
		self.finish(f"Crash Report Received!")