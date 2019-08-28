{% if page.comments && theme.gitalk.enable %}
  <link rel="stylesheet" href="https://unpkg.com/gitalk/dist/gitalk.css">
  <script src="https://unpkg.com/gitalk/dist/gitalk.min.js"></script>
  <script src="https://cdn.bootcss.com/blueimp-md5/2.10.0/js/md5.min.js"></script>
   <script type="text/javascript">
        var gitalk = new Gitalk({
          clientID: '{{ theme.gitalk.cilient_iD }}',
          clientSecret: '{{ theme.gitalk.client_secret }}',
          repo: '{{ theme.gitalk.repo }}',
          owner: '{{ theme.gitalk.github_id }}',
          admin: ['{{ theme.gitalk.admin_user }}'],
          id: md5(window.location.pathname),
          distractionFreeMode: '{{ theme.gitalk.distraction_free_mode }}'
        })
        gitalk.render('gitalk-container')
       </script>
{% endif %}
