# encoding: UTF-8
require 'rubygems'
require 'regexp-examples'
require 'sinatra'
require 'pry'


enable :sessions 


before '/quizmaster' do
  params[:user_attempt] ||= ""

  pairs = IO.readlines('public/' + params[:quiz]).each_slice(2).to_a
  @pairs = pairs.each { |pair| pair.map! { |string| string.chomp } }


  session[:question_wording] = @pairs[params[:q].to_i][0]
  session[:question_answers] = eval(pairs[params[:q].to_i][1]).examples
  
  @current_question_wording = session[:question_wording]
  @current_question_answers = session[:question_answers]
end

helpers do 
  def decrease_attempt_number
    session[:attempt_number] -= 1
  end

  def reset_attempt_number
    session[:attempt_number] = 3
  end

  def attempt_number
    session[:attempt_number]
  end

  def update_points
    session[:points] += session[:attempt_number] ** 2
  end

  def reset_points
    session[:points] = 0
  end

  def user_attempt_is_correct
    clean_attempt = params[:user_attempt].split.join(" ")
    session[:question_answers].include?(clean_attempt)
  end

  def reset_attempts
    session[:attempts] = []
    @attempts = session[:attempts]
  end

  def quiz_finished
    params[:q].to_i == @pairs.size - 1
  end
end

get '/' do
  erb :select
end

post '/' do
  erb :select
end

get '/quizmaster' do  
  reset_attempts
  reset_attempt_number
  reset_points if params[:q].to_i == 0
  @feedback = "Translate the following sentence!"
  @status = 'reset'
  erb :quiz
end

post '/quizmaster' do
  @attempts = session[:attempts]

  if user_attempt_is_correct
    update_points
    decrease_attempt_number
    @attempts << params[:user_attempt]
    @feedback = "That is correct!"
    @status = 'correct'
    
  elsif !user_attempt_is_correct && attempt_number > 1
    decrease_attempt_number
    @attempts << params[:user_attempt]
    @feedback = 'Sorry, that is incorrect.'
    @status = 'incorrect'
    
  elsif !user_attempt_is_correct
    decrease_attempt_number
    @attempts << params[:user_attempt]
    @feedback = "Failure!"    
    @status = 'failure'
  end

  erb :quiz
end

