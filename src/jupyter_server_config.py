c=get_config()
c.ServerApp.ip='*'
c.ServerApp.allow_credentials = False
c.ServerApp.port = 8888
c.ServerApp.password_required = True