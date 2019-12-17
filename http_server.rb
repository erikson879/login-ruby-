# http_server.rb
require 'socket'
require 'rack'
require 'rack/lobster'
require "cgi"
require_relative 'Datos'

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
      if Datos.new.valida_usuario(usuario.first,clave.first) #validaAcceso(usuario.first,clave.first) 
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
  elsif path == "/registro"      
    if query != nil
      query = CGI::parse(query)
      usuario = query["usuario"].first
      clave = query["clave"].first
      nombre = query["nombre"].first
      apellido = query["apellido"].first
      reg = {'usuario' => usuario,'clave' => clave,'nombre' => nombre,'apellido' => apellido}
      nuevo = Datos.new.insertaRegistro(reg)      
      #doc = File.open("satisfactorio.html")
      doc = File.read("satisfactorio.html")
      data = Datos.new.get_registros
      filas = ""
      data.each_hash do |row| 
            filas = filas + '<tr><td>'+row['login']+'</td><td>'+row['nombre']+'</td><td>'+row['apellido']+'</td></tr>'                              
      end
      data.close
      doc = doc.gsub(/filas/,filas)
      longitud = doc.size
      headers = {'Content-Type' => 'text/html', 'Content-Length' => longitud}
      status = 200
    else
      doc = File.open("satisfactorio.html")
      longitud = doc.size
      headers = {'Content-Type' => 'text/html', 'Content-Length' => longitud}
      status = 200
    end
    
  elsif path == "/acceso"      
    doc = File.open("acceso.html")
    longitud = doc.size
    headers = {'Content-Type' => 'text/html', 'Content-Length' => longitud}
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
    if doc.class == File
      doc.each do |part|
        #puts part
        session.print part
      end
    else
      session.print doc
    end

    
  else
    body.each do |part|
      #puts part
      session.print part
    end
  end  
  session.close
end
