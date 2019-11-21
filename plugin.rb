# name: mailing-list-suppress-user
# version: 0.1.0
# authors: Muhlis Budi Cahyono (muhlisbc@gmail.com)

enabled_site_setting :mailing_list_suppress_user_enabled

after_initialize do

  require_dependency "jobs/regular/notify_mailing_list_subscribers"
  class ::Jobs::NotifyMailingListSubscribers
    alias_method :orig_execute, :execute

    def execute(args)
      return orig_execute(args) if !SiteSetting.mailing_list_suppress_user_enabled

      post_id = args[:post_id]
      post = post_id ? Post.with_deleted.find_by(id: post_id) : nil

      return if !post

      if post.user&.username == SiteSetting.mailing_list_suppress_user_username
        return
      end

      orig_execute(args)
    end
  end

end
