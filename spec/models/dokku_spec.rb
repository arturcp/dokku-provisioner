# frozen_string_literal: true

require_relative "../../models/dokku.rb"

RSpec.describe Dokku, type: :model do
  subject(:dokku) { described_class.new(params) }

  let(:app) { "unity-bit" }
  let(:domain) { "unitybit.com" }
  let(:https) { true }
  let(:postgresql) { true }
  let(:redis) { true }

  let(:env_vars) do
    [
      "SITE_URL=https://my.site.com\n",
      "SECRET_TOKEN=ABCD1234\n",
      "WEBHOOK_URL=https://my.webhook.com/message\n"
    ]
  end

  let(:params) do
    {
      app: app,
      domain: domain,
      postgresql: postgresql,
      redis: redis,
      https: https,
      env_vars: env_vars
    }
  end

  describe "#instructions" do
    context "create" do
      let(:instructions) { dokku.instructions[:create] }

      context "when app is all lowercase" do
        it { expect(instructions).to include("dokku apps:create unity-bit") }
      end

      context "when app is not all lowercase" do
        let(:app) { "Unity-Bit" }

        it { expect(instructions).to include("dokku apps:create unity-bit") }
      end

      context "when domain is present" do
        it { expect(instructions).to include("dokku domains:add unity-bit unitybit.com") }
      end

      context "when domain is not present" do
        let(:domain) { nil }

        it "does not include instructions to add a domain" do
          instructions.each do |instruction|
            expect(instruction).not_to include("dokku domains:add")
          end
        end
      end

      context "when postgresql is true" do
        let(:postgresql) { true }

        it { expect(instructions).to include("dokku postgres:create unity-bit-database") }
        it { expect(instructions).to include("dokku postgres:link unity-bit-database unity-bit") }
      end

      context "when postgresql is false" do
        let(:postgresql) { false }

        it { expect(instructions).not_to include("dokku postgres:create unity-bit-database") }
        it { expect(instructions).not_to include("dokku postgres:link unity-bit-database unity-bit") }
      end

      context "when postgresql is nil" do
        let(:postgresql) { nil }

        it { expect(instructions).not_to include("dokku postgres:create unity-bit-database") }
        it { expect(instructions).not_to include("dokku postgres:link unity-bit-database unity-bit") }
      end

      context "when redis is true" do
        let(:redis) { true }

        it { expect(instructions).to include("dokku redis:create unity-bit-redis") }
        it { expect(instructions).to include("dokku redis:link unity-bit-redis unity-bit") }
      end

      context "when redis is false" do
        let(:redis) { false }

        it { expect(instructions).not_to include("dokku redis:create unity-bit-redis") }
        it { expect(instructions).not_to include("dokku redis:link unity-bit-redis unity-bit") }
      end

      context "when redis is nil" do
        let(:redis) { nil }

        it { expect(instructions).not_to include("dokku redis:create unity-bit-redis") }
        it { expect(instructions).not_to include("dokku redis:link unity-bit-redis unity-bit") }
      end

      context "when env vars is present" do
        it { expect(instructions).to include("dokku config:set --no-restart unity-bit SITE_URL=https://my.site.com") }
        it { expect(instructions).to include("dokku config:set --no-restart unity-bit SECRET_TOKEN=ABCD1234") }
        it { expect(instructions).to include("dokku config:set --no-restart unity-bit WEBHOOK_URL=https://my.webhook.com/message") }
      end

      context "when env vars is not present" do
        let(:env_vars) { [] }

        it { expect(instructions).not_to include("dokku config:set --no-restart unity-bit SITE_URL=https://my.site.com") }
        it { expect(instructions).not_to include("dokku config:set --no-restart unity-bit SECRET_TOKEN=ABCD1234") }
        it { expect(instructions).not_to include("dokku config:set --no-restart unity-bit WEBHOOK_URL=https://my.webhook.com/message") }
      end

      it { expect(instructions).to include("dokku proxy:ports-set unity-bit http:80:5000") }

    end
  end
end
