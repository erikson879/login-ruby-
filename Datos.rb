require 'sqlite3'

@@db= nil

class Datos 
	def initialize
		@@db = SQLite3::Database.new('solicionoo.db');
    end
	def insertaRegistro(dataHash)
		usuario = dataHash['usuario']		
		clave = dataHash['clave']
		nombre = dataHash['nombre']
		apellido = dataHash['apellido']
	    sentencia = "INSERT INTO solucion00 ( login, password, nombre, apellido) VALUES ( \'%s\',\'%s\',\'%s\',\'%s\' );" % [usuario,clave,nombre,apellido]
	    @@db.execute(sentencia)
		#return sentencia
	end
	def get_registros
		stm = @@db.prepare "SELECT login, nombre, apellido FROM solucion00;"
		rs = stm.execute
		return rs
	end
	def valida_usuario(usuario,clave)
		re = false
		begin
			stm = @@db.prepare "SELECT * FROM solucion00 WHERE login=? and password=?;"
		    stm.bind_param 1, usuario
		    stm.bind_param 2, clave	    
		    rs = stm.execute
		    row = rs.next
		    if row != nil 
		    	re = true
		    end
	    rescue SQLite3::Exception => e 
		    puts "Exception occurred"
		    puts e
	    ensure
	    	stm.close if stm
    		@@db.close if @@db
	    end
	    return re
	end
end


