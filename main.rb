require 'pry'
require 'sinatra'
require 'sinatra/reloader' if development?
require "httparty"
require "json"
require "pg"

get '/' do
  erb :homepage
end

get '/faq' do
  erb :faq
end

get '/about' do
  erb :about
end

get '/' do
  @title = params[:title]
  if (@title.nil? || @title == '')
#    @poster = "home-bloghero.png"
    @message = '' # put in logic to display an image and say this movie does not exist.
  else
    moviez = @title.gsub(" ","+")
    url = "http://www.omdbapi.com/?i=&t=#{moviez}"
    movie_string = HTTParty.get(url)
    movie = JSON(movie_string)
    imdbID = movie["imdbID"]
    @movie_name = movie["Title"].gsub("'","''")
    year = movie["Year"]
    rated = movie["Rated"].gsub("'","''")
    released = movie["Released"].gsub("'","''")
    runtime = movie["Runtime"]
    genre = movie["Genre"]
    director = movie["Director"].gsub("'","''")
    writers = movie["Writer"].gsub("'","''")
    @actors = movie["Actors"].gsub("'","''")
    @plot = movie["Plot"].gsub("'","''")
    @poster = movie["Poster"]


#if imdbID != nil
      sql = "INSERT INTO movies (title,year,rated,released,runtime,genre,director,writers,
        actors,plot,poster) VALUES
      ('#{@movie_name}','#{year}','#{rated}','#{released}','#{runtime}','#{genre}',
        '#{director}', '#{writers}','#{@actors}','#{@plot}','#{@poster}')";
      binding.pry
#      begin
        conn = PG.connect(:dbname => 'movie_app', :host => 'localhost')
        conn.exec(sql)
        conn.close
#       rescue PG::Error => err
#        puts ("The movie #{stitle}:  #{err}")
#     ensure
#      end

# conn.exec("select * from movies where title = '#{@movie_name}'") do |result|
#        result.each do |row|
#         @actors = row["Actors"].gsub("'","''")
#         @plot = row["Plot"].gsub("'","''")
#         @poster = row["Poster"]
# end

    binding.pry
end

      erb :movie
end

get '/movies' do
  query = "SELECT poster, title from movies"
  conn = PG.connect(:dbname => 'movie_app', :host => 'localhost')
  @result = conn.exec(query)
  conn.close
  erb :posters
end