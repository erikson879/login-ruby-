# http_server.rb
require 'socket'
require 'rack'
require 'rack/lobster'
require "cgi"

def validaAcceso (usuario,clave)
  foo = false
  if "myUser"==usuario  && "12345"==clave
     foo =true
  end
  return foo
end

server = TCPServer.new 5678

while session = server.accept
  request = session.gets
  
  # 1
  method, full_path = request.split(' ')
  # 2
  path, query = full_path.split('?')
  doc = nil
  status = 400
  if path == "/login.html" || path == "/"
    if query != nil
      query = CGI::parse(query)
      usuario = query['usuario']
      clave = query['clave']
      if validaAcceso(usuario.first,clave.first) 
        doc = File.open("acceso.html")
        longitud = doc.size
        headers = {'Content-Type' => 'text/html', 'Content-Length' => longitud}
        status = 200
      else 
        puts "estatus 400"
        doc = File.open("negado.html")
        longitud = doc.size
        headers = {'Content-Type' => 'text/html', 'Content-Length' => longitud}
        status = 200
      end
    else
      doc = File.open("login.html")
      longitud = doc.size
      headers = {'Content-Type' => 'text/html', 'Content-Length' => longitud}
      status = 200
    end
  elsif path == "/bootstrap.min.css"  
    doc = File.open("bootstrap.min.css")
    longitud = doc.size
    headers = {'Content-Type' => 'text/css', 'Content-Length' => longitud}
    status = 200
  elsif status == 400  
    doc = File.open("negado.html")
    longitud = doc.size
    headers = {'Content-Type' => 'text/html', 'Content-Length' => longitud}
    status = 200  
  end
  # 3  
  session.print "HTTP/1.1 #{status}\r\n"
  headers.each do |key, value|
    session.print "#{key}: #{value}\r\n"
  end
  session.print "\r\n"
  if doc != nil 
    doc.each do |part|
      #puts part
      session.print part
    end
  else
    body.each do |part|
      #puts part
      session.print part
    end
  end  
  session.close
end
