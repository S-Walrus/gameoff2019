function love.conf(t)
	t.window.vsync = 1
	t.window.resizable = true
	t.window.fullscreen = true
	t.window.title = "Bordered"
	t.window.icon = "icon.png"
	t.releases = {
	    title = "Bordered",
	    version = 1.0,
	    author = "swalrus",
	    email = "swalrus@yandex.ru",
	    excludeFileList = {},
	    releaseDirectory = "build",
	    identifier = "com.swalrus.bordered",
	    description = "Relaxing yet challenging abstract game",
	    homepage = "https://swalrus.itch.io/bordered",
	    version = "1.0"
    }
end
