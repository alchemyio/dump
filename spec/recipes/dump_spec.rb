require File.dirname(__FILE__) + '/../spec_helper'
require 'capistrano'

describe "cap dump" do
  before do
    @cap = Capistrano::Configuration.new
    @cap.load File.dirname(__FILE__) + '/../../recipes/dump.rb'
    @remote_path = "/home/test/apps/dummy"
    @cap.set(:current_path, @remote_path)
  end

  def all_dictionary_variables
    DumpRake::Env.dictionary.each_with_object({}) do |(key, value), filled_env|
      filled_env[key] = value.join(' ')
    end
  end

  describe "local" do
    describe "versions" do
      it "should call local rake task" do
        @cap.dump.should_receive(:run_local).with("rake -s dump:versions").and_return('')
        @cap.find_and_execute_task("dump:local:versions")
      end

      DumpRake::Env.dictionary[:like].each do |name|
        it "should pass version if it is set through environment variable #{name}" do
          @cap.dump.should_receive(:run_local).with("rake -s dump:versions LIKE=21376").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:local:versions")
          end
        end
      end

      DumpRake::Env.dictionary[:tags].each do |name|
        it "should pass tags through environment variable #{name}" do
          @cap.dump.should_receive(:run_local).with("rake -s dump:versions TAGS=21376").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:local:versions")
          end
        end
      end

      it "should print result of rake task" do
        @cap.dump.stub!(:run_local).and_return("123123.tgz\n")
        grab_output{
          @cap.find_and_execute_task("dump:local:versions")
        }[:stdout].should == "123123.tgz\n"
      end
    end

    describe "cleanup" do
      it "should call local rake task" do
        @cap.dump.should_receive(:run_local).with("rake -s dump:cleanup").and_return('')
        @cap.find_and_execute_task("dump:local:cleanup")
      end

      DumpRake::Env.dictionary[:like].each do |name|
        it "should pass version if it is set through environment variable #{name}" do
          @cap.dump.should_receive(:run_local).with("rake -s dump:cleanup LIKE=21376").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:local:cleanup")
          end
        end
      end

      DumpRake::Env.dictionary[:tags].each do |name|
        it "should pass tags through environment variable #{name}" do
          @cap.dump.should_receive(:run_local).with("rake -s dump:cleanup TAGS=21376").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:local:cleanup")
          end
        end
      end

      DumpRake::Env.dictionary[:leave].each do |name|
        it "should pass tags through environment variable #{name}" do
          @cap.dump.should_receive(:run_local).with("rake -s dump:cleanup LEAVE=21376").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:local:cleanup")
          end
        end
      end

      it "should print result of rake task" do
        @cap.dump.stub!(:run_local).and_return("123123.tgz\n")
        grab_output{
          @cap.find_and_execute_task("dump:local:cleanup")
        }[:stdout].should == "123123.tgz\n"
      end
    end

    describe "create" do
      it "should raise if dump creation fails" do
        @cap.dump.should_receive(:run_local).with("rake -s dump:create TAGS=local").and_return('')
        proc{
          @cap.find_and_execute_task("dump:local:create")
        }.should raise_error('Failed creating dump')
      end

      it "should call local rake task with tag local" do
        @cap.dump.should_receive(:run_local).with("rake -s dump:create TAGS=local").and_return('123.tgz')
        grab_output{
          @cap.find_and_execute_task("dump:local:create")
        }
      end

      it "should call local rake task with additional tag local" do
        @cap.dump.should_receive(:run_local).with("rake -s dump:create TAGS=local,photos").and_return('123.tgz')
        grab_output{
          DumpRake::Env.with_env :tags => 'photos' do
            @cap.find_and_execute_task("dump:local:create")
          end
        }
      end

      DumpRake::Env.dictionary[:desc].each do |name|
        it "should pass description if it is set through environment variable #{name}" do
          @cap.dump.should_receive(:run_local).with("rake -s dump:create 'DESC=local dump' TAGS=local").and_return('123.tgz')
          DumpRake::Env.with_env name => 'local dump' do
            grab_output{
              @cap.find_and_execute_task("dump:local:create")
            }
          end
        end
      end

      it "should print result of rake task" do
        @cap.dump.stub!(:run_local).and_return("123123.tgz\n")
        grab_output{
          @cap.find_and_execute_task("dump:local:create")
        }[:stdout].should == "123123.tgz\n"
      end

      it "should return stripped result of rake task" do
        @cap.dump.stub!(:run_local).and_return("123123.tgz\n")
        grab_output{
          @cap.find_and_execute_task("dump:local:create").should == "123123.tgz"
        }
      end
    end

    describe "restore" do
      it "should call local rake task" do
        @cap.dump.should_receive(:run_local).with("rake -s dump:restore")
        @cap.find_and_execute_task("dump:local:restore")
      end

      DumpRake::Env.dictionary[:like].each do |name|
        it "should pass version if it is set through environment variable #{name}" do
          @cap.dump.should_receive(:run_local).with("rake -s dump:restore LIKE=21376")
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:local:restore")
          end
        end
      end

      DumpRake::Env.dictionary[:tags].each do |name|
        it "should pass tags through environment variable #{name}" do
          @cap.dump.should_receive(:run_local).with("rake -s dump:restore TAGS=21376")
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:local:restore")
          end
        end
      end
    end

    describe "upload" do
      it "should run rake versions to get avaliable versions" do
        @cap.dump.should_receive(:run_local).with("rake -s dump:versions").and_return('')
        @cap.find_and_execute_task("dump:local:upload")
      end

      DumpRake::Env.dictionary[:like].each do |name|
        it "should pass version if it is set through environment variable #{name}" do
          @cap.dump.should_receive(:run_local).with("rake -s dump:versions LIKE=21376").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:local:upload")
          end
        end
      end

      DumpRake::Env.dictionary[:tags].each do |name|
        it "should pass tags through environment variable #{name}" do
          @cap.dump.should_receive(:run_local).with("rake -s dump:versions TAGS=21376").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:local:upload")
          end
        end
      end

      it "should not upload anything if there are no versions avaliable" do
        @cap.dump.stub!(:run_local).and_return('')
        @cap.should_not_receive(:transfer)
        @cap.find_and_execute_task("dump:local:upload")
      end

      it "should transfer latest version dump" do
        @cap.dump.stub!(:run_local).and_return("100.tgz\n200.tgz\n300.tgz\n")
        @cap.should_receive(:transfer).with(:up, "dump/300.tgz", "#{@remote_path}/dump/300.tgz", :via => :scp)
        @cap.find_and_execute_task("dump:local:upload")
      end

      it "should handle extra spaces around file names" do
        @cap.dump.stub!(:run_local).and_return("\r\n\r\n\r  100.tgz   \r\n\r\n\r  200.tgz   \r\n\r\n\r  300.tgz   \r\n\r\n\r  ")
        @cap.should_receive(:transfer).with(:up, "dump/300.tgz", "#{@remote_path}/dump/300.tgz", :via => :scp)
        @cap.find_and_execute_task("dump:local:upload")
      end
    end
  end

  describe "remote" do
    describe "versions" do
      it "should call remote rake task" do
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:versions PROGRESS_TTY=+ RAILS_ENV=production").and_return('')
        @cap.find_and_execute_task("dump:remote:versions")
      end

      DumpRake::Env.dictionary[:like].each do |name|
        it "should pass version if it is set through environment variable #{name}" do
          @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:versions LIKE=21376 PROGRESS_TTY=+ RAILS_ENV=production").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:remote:versions")
          end
        end
      end

      DumpRake::Env.dictionary[:tags].each do |name|
        it "should pass tags through environment variable #{name}" do
          @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:versions PROGRESS_TTY=+ RAILS_ENV=production TAGS=21376").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:remote:versions")
          end
        end
      end

      it "should print result of rake task" do
        @cap.dump.stub!(:run_remote).and_return("123123.tgz\n")
        grab_output{
          @cap.find_and_execute_task("dump:remote:versions")
        }[:stdout].should == "123123.tgz\n"
      end

      it "should use custom rake binary" do
        @cap.dump.should_receive(:fetch_rake).and_return('/custom/rake')
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; /custom/rake -s dump:versions PROGRESS_TTY=+ RAILS_ENV=production").and_return('')
        @cap.find_and_execute_task("dump:remote:versions")
      end
    end

    describe "cleanup" do
      it "should call remote rake task" do
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:cleanup PROGRESS_TTY=+ RAILS_ENV=production").and_return('')
        @cap.find_and_execute_task("dump:remote:cleanup")
      end

      DumpRake::Env.dictionary[:like].each do |name|
        it "should pass version if it is set through environment variable #{name}" do
          @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:cleanup LIKE=21376 PROGRESS_TTY=+ RAILS_ENV=production").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:remote:cleanup")
          end
        end
      end

      DumpRake::Env.dictionary[:tags].each do |name|
        it "should pass tags through environment variable #{name}" do
          @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:cleanup PROGRESS_TTY=+ RAILS_ENV=production TAGS=21376").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:remote:cleanup")
          end
        end
      end

      DumpRake::Env.dictionary[:leave].each do |name|
        it "should pass tags through environment variable #{name}" do
          @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:cleanup LEAVE=21376 PROGRESS_TTY=+ RAILS_ENV=production").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:remote:cleanup")
          end
        end
      end

      it "should print result of rake task" do
        @cap.dump.stub!(:run_remote).and_return("123123.tgz\n")
        grab_output{
          @cap.find_and_execute_task("dump:remote:cleanup")
        }[:stdout].should == "123123.tgz\n"
      end

      it "should use custom rake binary" do
        @cap.dump.should_receive(:fetch_rake).and_return('/custom/rake')
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; /custom/rake -s dump:cleanup PROGRESS_TTY=+ RAILS_ENV=production").and_return('')
        @cap.find_and_execute_task("dump:remote:cleanup")
      end
    end

    describe "create" do
      it "should raise if dump creation fails" do
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:create PROGRESS_TTY=+ RAILS_ENV=production TAGS=remote").and_return('')
        proc{
          @cap.find_and_execute_task("dump:remote:create")
        }.should raise_error('Failed creating dump')
      end

      it "should call remote rake task with default rails_env and tag remote" do
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:create PROGRESS_TTY=+ RAILS_ENV=production TAGS=remote").and_return('123.tgz')
        grab_output{
          @cap.find_and_execute_task("dump:remote:create")
        }
      end

      it "should call remote rake task with default rails_env and additional tag remote" do
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:create PROGRESS_TTY=+ RAILS_ENV=production TAGS=remote,photos").and_return('123.tgz')
        grab_output{
          DumpRake::Env.with_env :tags => 'photos' do
            @cap.find_and_execute_task("dump:remote:create")
          end
        }
      end

      it "should call remote rake task with fetched rails_env and default DESC remote" do
        @cap.dump.should_receive(:fetch_rails_env).and_return('dev')
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:create PROGRESS_TTY=+ RAILS_ENV=dev TAGS=remote").and_return('123.tgz')
        grab_output{
          @cap.find_and_execute_task("dump:remote:create")
        }
      end

      DumpRake::Env.dictionary[:desc].each do |name|
        it "should pass description if it is set through environment variable #{name}" do
          @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:create 'DESC=remote dump' PROGRESS_TTY=+ RAILS_ENV=production TAGS=remote").and_return('123.tgz')
          DumpRake::Env.with_env name => 'remote dump' do
            grab_output{
              @cap.find_and_execute_task("dump:remote:create")
            }
          end
        end
      end

      it "should print result of rake task" do
        @cap.dump.stub!(:run_remote).and_return("123123.tgz\n")
        grab_output{
          @cap.find_and_execute_task("dump:remote:create")
        }[:stdout].should == "123123.tgz\n"
      end

      it "should return stripped result of rake task" do
        @cap.dump.stub!(:run_remote).and_return("123123.tgz\n")
        grab_output{
          @cap.find_and_execute_task("dump:remote:create").should == "123123.tgz"
        }
      end

      it "should use custom rake binary" do
        @cap.dump.should_receive(:fetch_rake).and_return('/custom/rake')
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; /custom/rake -s dump:create PROGRESS_TTY=+ RAILS_ENV=production TAGS=remote").and_return('123.tgz')
        grab_output{
          @cap.find_and_execute_task("dump:remote:create")
        }
      end
    end

    describe "restore" do
      it "should call remote rake task with default rails_env" do
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:restore PROGRESS_TTY=+ RAILS_ENV=production")
        @cap.find_and_execute_task("dump:remote:restore")
      end

      it "should call remote rake task with fetched rails_env" do
        @cap.dump.should_receive(:fetch_rails_env).and_return('dev')
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:restore PROGRESS_TTY=+ RAILS_ENV=dev")
        @cap.find_and_execute_task("dump:remote:restore")
      end

      DumpRake::Env.dictionary[:like].each do |name|
        it "should pass version if it is set through environment variable #{name}" do
          @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:restore LIKE=21376 PROGRESS_TTY=+ RAILS_ENV=production")
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:remote:restore")
          end
        end
      end

      DumpRake::Env.dictionary[:tags].each do |name|
        it "should pass tags through environment variable #{name}" do
          @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:restore PROGRESS_TTY=+ RAILS_ENV=production TAGS=21376")
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:remote:restore")
          end
        end
      end

      it "should use custom rake binary" do
        @cap.dump.should_receive(:fetch_rake).and_return('/custom/rake')
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; /custom/rake -s dump:restore PROGRESS_TTY=+ RAILS_ENV=production")
        @cap.find_and_execute_task("dump:remote:restore")
      end
    end

    describe "download" do
      it "should run rake versions to get avaliable versions" do
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:versions PROGRESS_TTY=+ RAILS_ENV=production").and_return('')
        @cap.find_and_execute_task("dump:remote:download")
      end

      DumpRake::Env.dictionary[:like].each do |name|
        it "should pass version if it is set through environment variable #{name}" do
          @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:versions LIKE=21376 PROGRESS_TTY=+ RAILS_ENV=production").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:remote:download")
          end
        end
      end

      DumpRake::Env.dictionary[:tags].each do |name|
        it "should pass tags through environment variable #{name}" do
          @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; rake -s dump:versions PROGRESS_TTY=+ RAILS_ENV=production TAGS=21376").and_return('')
          DumpRake::Env.with_env name => '21376' do
            @cap.find_and_execute_task("dump:remote:download")
          end
        end
      end

      it "should not download anything if there are no versions avaliable" do
        @cap.dump.stub!(:run_remote).and_return('')
        @cap.should_not_receive(:transfer)
        @cap.find_and_execute_task("dump:remote:download")
      end

      it "should transfer latest version dump" do
        @cap.dump.stub!(:run_remote).and_return("100.tgz\n200.tgz\n300.tgz\n")
        @cap.should_receive(:transfer).with(:down, "#{@remote_path}/dump/300.tgz", "dump/300.tgz", :via => :scp)
        FileUtils.stub!(:mkpath)
        @cap.find_and_execute_task("dump:remote:download")
      end

      it "should handle extra spaces around file names" do
        @cap.dump.stub!(:run_remote).and_return("\r\n\r\n\r  100.tgz   \r\n\r\n\r  200.tgz   \r\n\r\n\r  300.tgz   \r\n\r\n\r  ")
        @cap.should_receive(:transfer).with(:down, "#{@remote_path}/dump/300.tgz", "dump/300.tgz", :via => :scp)
        FileUtils.stub!(:mkpath)
        @cap.find_and_execute_task("dump:remote:download")
      end

      it "should create local dump dir" do
        @cap.dump.stub!(:run_remote).and_return("100.tgz\n200.tgz\n300.tgz\n")
        @cap.stub!(:transfer)
        FileUtils.should_receive(:mkpath).with('dump')
        @cap.find_and_execute_task("dump:remote:download")
      end

      it "should run rake versions use custom rake binary" do
        @cap.dump.should_receive(:fetch_rake).and_return('/custom/rake')
        @cap.dump.should_receive(:run_remote).with("cd #{@remote_path}; /custom/rake -s dump:versions PROGRESS_TTY=+ RAILS_ENV=production").and_return('')
        @cap.find_and_execute_task("dump:remote:download")
      end
    end
  end

  describe "mirror" do
    {"up" => [:local, :remote], "down" => [:remote, :local]}.each do |dir, way|
      src = way[0]
      dst = way[1]
      describe name do
        it "should create auto-backup with tag auto-backup" do
          @cap.dump.namespaces[dst].should_receive(:create){ DumpRake::Env[:tags].should == 'auto-backup'; '' }
          @cap.find_and_execute_task("dump:mirror:#{dir}")
        end

        it "should create auto-backup with additional tag auto-backup" do
          @cap.dump.namespaces[dst].should_receive(:create){ DumpRake::Env[:tags].should == 'auto-backup,photos'; '' }
          DumpRake::Env.with_env :tags => 'photos' do
            @cap.find_and_execute_task("dump:mirror:#{dir}")
          end
        end

        it "should not call local:create if auto-backup fails" do
          @cap.dump.namespaces[dst].stub!(:create).and_return('')
          @cap.dump.namespaces[src].should_not_receive(:create)
          @cap.find_and_execute_task("dump:mirror:#{dir}")
        end

        it "should call local:create if auto-backup succeedes with tags mirror and mirror-#{dir}" do
          @cap.dump.namespaces[dst].stub!(:create).and_return('123.tgz')
          @cap.dump.namespaces[src].should_receive(:create){ DumpRake::Env[:tags].should == "mirror,mirror-#{dir}"; '' }
          @cap.find_and_execute_task("dump:mirror:#{dir}")
        end

        it "should call local:create if auto-backup succeedes with additional tags mirror and mirror-#{dir}" do
          @cap.dump.namespaces[dst].stub!(:create).and_return('123.tgz')
          @cap.dump.namespaces[src].should_receive(:create){ DumpRake::Env[:tags].should == "mirror,mirror-#{dir},photos"; '' }
          DumpRake::Env.with_env :tags => 'photos' do
            @cap.find_and_execute_task("dump:mirror:#{dir}")
          end
        end

        it "should not call local:upload or remote:restore if local:create fails" do
          @cap.dump.namespaces[dst].stub!(:create).and_return('123.tgz')
          @cap.dump.namespaces[src].stub!(:create).and_return('')
          @cap.dump.namespaces[src].should_not_receive(:upload)
          @cap.dump.namespaces[dst].should_not_receive(:restore)
          @cap.find_and_execute_task("dump:mirror:#{dir}")
        end

        it "should call local:upload and remote:restore with only varibale ver set to file name if local:create returns file name" do
          @cap.dump.namespaces[dst].stub!(:create).and_return('123.tgz')
          @cap.dump.namespaces[src].stub!(:create).and_return('123.tgz')
          test_env = proc{
            DumpRake::Env[:like].should == '123.tgz'
            DumpRake::Env[:tags].should == nil
            DumpRake::Env[:desc].should == nil
          }
          @cap.dump.namespaces[src].should_receive(:"#{dir}load").ordered(&test_env)
          @cap.dump.namespaces[dst].should_receive(:restore).ordered(&test_env)
          DumpRake::Env.with_env all_dictionary_variables do
            @cap.find_and_execute_task("dump:mirror:#{dir}")
          end
        end
      end
    end
  end

  describe "backup" do
    it "should call remote:create" do
      @cap.dump.remote.should_receive(:create).and_return('')
      @cap.find_and_execute_task("dump:backup")
    end

    it "should not call remote:download if remote:create returns blank" do
      @cap.dump.remote.stub!(:create).and_return('')
      @cap.dump.remote.should_not_receive(:download)
      @cap.find_and_execute_task("dump:backup")
    end

    it "should call remote:download if remote:create returns file name" do
      @cap.dump.remote.stub!(:create).and_return('123.tgz')
      @cap.dump.remote.should_receive(:download).ordered
      @cap.find_and_execute_task("dump:backup")
    end

    it "should call remote:create with tag backup" do
      def (@cap.dump.remote).create
        DumpRake::Env[:tags].should == 'backup'
        ''
      end
      @cap.find_and_execute_task("dump:backup")
    end

    it "should call remote:create with additional tag backup" do
      def (@cap.dump.remote).create
        DumpRake::Env[:tags].should == 'backup,photos'
        ''
      end
      DumpRake::Env.with_env :tags => 'photos' do
        @cap.find_and_execute_task("dump:backup")
      end
    end

    it "should pass description if it is set" do
      def (@cap.dump.remote).create
        DumpRake::Env[:desc].should == 'remote dump'
        ''
      end
      DumpRake::Env.with_env :desc => 'remote dump' do
        @cap.find_and_execute_task("dump:backup")
      end
    end

    it "should send only ver variable" do
      @cap.dump.remote.stub!(:create).and_return('123.tgz')
      def (@cap.dump.remote).download
        DumpRake::Env[:like].should == '123.tgz'
        DumpRake::Env[:tags].should == nil
        DumpRake::Env[:desc].should == nil
        ''
      end
      DumpRake::Env.with_env all_dictionary_variables do
        @cap.find_and_execute_task("dump:backup")
      end
    end
  end
end
