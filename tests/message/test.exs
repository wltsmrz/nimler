
ExUnit.start(trace: false, seed: 0)

defmodule NimlerMessage.Test do
    use ExUnit.Case, async: false
    alias NimlerMessage, as: NimlerWrapper

    setup do
      {:ok, [mymsg: 123]}
    end

    test "send_message()", context do
      assert(:ok == NimlerWrapper.send_message(self(), context[:mymsg]))
      receive do msg -> assert(msg == context[:mymsg]) end
    end

    test "send_message_caller()", context do
      assert(:ok == NimlerWrapper.send_message_caller(context[:mymsg]))
      receive do msg -> assert(msg == context[:mymsg]) end
    end
end

