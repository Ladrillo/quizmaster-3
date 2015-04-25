# encoding: UTF-8
require 'rubygems'
require 'regexp-examples'
require 'sinatra'
require 'pry'


enable :sessions 


before do
  pairs = IO.readlines('public/' + params[:quiz]).each_slice(2).to_a
  @pairs = pairs.each { |pair| pair.map! { |string| string.chomp } }


  session[:question_wording] = @pairs[0][0]
  session[:question_answers] = eval(pairs[0][1]).examples

  
  @current_question_wording = session[:question_wording]
  @current_question_answer = session[:question_answers].sample
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

  def attempt_is_correct
    session[:question_answers].include?(params[:answer_attempt])
  end

  def reset_attempts
    session[:attempts] = []
    @attempts = session[:attempts]
  end
end


get '/quizmaster' do
  reset_attempts
  reset_attempt_number
  @feedback = "Translate the following sentence!"
  @status = 'reset'
  erb :quiz
end


post '/quizmaster' do
  @attempts = session[:attempts]

  if attempt_is_correct    
    decrease_attempt_number
    @attempts << params[:answer_attempt]
    @feedback = "That is correct!"
    @status = 'correct'
    
  elsif !attempt_is_correct && attempt_number > 1
    decrease_attempt_number
    @attempts << params[:answer_attempt]
    @feedback = 'Sorry, that is incorrect.'
    @status = 'incorrect'
    
  elsif !attempt_is_correct  
    decrease_attempt_number
    @attempts << params[:answer_attempt]
    @feedback = "Failure!"    
    @status = 'failure'
  end

  erb :quiz
end

