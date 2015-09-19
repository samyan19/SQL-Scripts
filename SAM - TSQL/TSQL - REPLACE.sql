					UPDATE ASSET.Asset
						SET EPIC = REPLACE(EPIC, '/', '.')
					WHERE EPIC like '%/%' 