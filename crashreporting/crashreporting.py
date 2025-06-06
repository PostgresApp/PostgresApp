import tornado.websocket
import json
import os
import asyncio
import asyncpg

class CrashReporting(tornado.web.RequestHandler):

	async def post(self, path):
		
		self.request.body
		
		await self.application.pg_pool.execute(
			"INSERT INTO crash_reports_raw(data) VALUES($1);",
			self.request.body
		)
		
		self.finish(f"Crash Report Received!")