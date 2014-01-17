require 'digest' #biblioteca para criptograr a senha
class User < ActiveRecord::Base
	attr_accessor :password #define um atributo de acesso (cria os métodos getters/setters para o atributos)
	#pq a coluna password não existe mais na tabela, e o método password não é criado automaticamente pelo Active Record
	#então precisa 'setar' o atributo password antes de ser criptografado
	#funciona como qualquer atributo, exceto que não é salvo no banco de dados quando o modelo é salvo

	validates_uniqueness_of :email #verifica se é unico no sistema
	validates_length_of :email, :within => 5..50
	validates_format_of :email, :with => /^[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}$/i, :multiline => true #expressão regular para validação de email
	
	validates_confirmation_of :password #cria um campo virtual para confirmação da senha
	validates_length_of :password, :within => 4..20
	validates_presence_of :password, :if => :password_required? #campo obrigatorio se a senha é obrigatoria

	has_one :profile
	has_many :articles, -> { order('published_at DESC, title ASC')}, :dependent => :nullify #método gerado no console pra acessar (user.articles)
	has_many :replies, :through => :articles, :source => :comments

	before_save :encrypt_new_password #faz com que o Active Record execute o método 'encrypt_new_password' antes de salvar o registro

	def self.authenticate(email, password) #método de classe(self). Acessa direto da classe o método(User.authenticate), não precisa instanciar a classe pra usar o método (User.new)
		#recebe como parametro email e uma senha não criptografada
		user = find_by_email(email) #se achar o email, o atributo user contem um valor.
		return user if user && user.authenticated?(password) #só acontece isso se 'user' possuir um valor e o método authenticated?(password) tiver o valor true
	end

	def authenticated?(password) #método que verifica se hashed_password é igual a senha depois de ter sido criptografada
		self.hashed_password == encrypt(password)
	end

	protected
		def encrypt_new_password #só executa o método se tiver algum valor preenchido, se estiver preenchido define o atributo hashed_password através do método encrypt 
			return if password.blank?
			self.hashed_password = encrypt(password)
		end

		def password_required? #ao realizar validações, é necessário apenas realizá-la se se for necessária essa validação. E é necessário somente se for um novo registro
			#ou se a senha é usada para definir uma nova senha.
			#para facilitar o trabalho, cria o metodo password_required? para retornar true se é necessário uma senha ou false caso contrario
			hashed_password.blank? || password.present? #present - retorna true se existe valor ou falso caso contrario
		end

		def encrypt(string) #usa a biblioteca 'digest' do Ruby que foi incluida na primeira linha 
			Digest::SHA1.hexdigest(string) #retorna a string criptografada
		end

end


