class MyTravelRequestsController < ApplicationController
  unloadable

  def index
    case
    when User.current.child?
      redirect_to issues_for_me
    when User.current.parent? && User.current.child.present?
      redirect_to issues_for_my_child
    else
      redirect_to :controller => 'issues', :action => 'index', :set_filter => 't'
    end
    
  end

  private

  # Query builder for issues I authored
  def issues_for_me
    default_issue_query.merge({'author_id' => 'me'})
  end

  # Query builder for issues my child authored
  def issues_for_my_child
    child = User.current.child
    if child.present?
      default_issue_query.merge({'author_id' => child.id})
    else
      default_issue_query
    end
  end

  # A default Query with GET filtering and sorted by updated_on
  def default_issue_query
    {
      :controller => 'issues',
      :action => 'index',
      :set_filter => 't',
      :sort => 'updated_on:desc'
    }
  end
  
end
