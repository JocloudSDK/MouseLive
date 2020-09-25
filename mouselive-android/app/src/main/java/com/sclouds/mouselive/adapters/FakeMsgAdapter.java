package com.sclouds.mouselive.adapters;

import android.content.Context;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.widget.TextView;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.datasource.bean.User;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.bean.FakeMessage;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.core.util.ObjectsCompat;

/**
 * @author xipeitao
 * @description 房间信息列表
 * @date 2020-01-17 16:20
 */
public class FakeMsgAdapter extends BaseAdapter<FakeMessage, FakeMsgAdapter.ViewHolder> {

    private User mine;
    private User owner;

    public FakeMsgAdapter(Context context, User mine, User owner) {
        super(context);
        this.mine = mine;
        this.owner = owner;
    }

    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.item_fakemsg_list;
    }

    @Override
    protected ViewHolder createViewHolder(@NonNull View itemView) {
        return new ViewHolder(itemView);
    }

    class ViewHolder extends BaseAdapter.BaseViewHolder<FakeMessage> {

        private TextView tvMsg;

        public ViewHolder(View itemView) {
            super(itemView);
            tvMsg = itemView.findViewById(R.id.iv_msg_user_txt);
        }

        @Override
        protected void bind(FakeMessage item) {
            User userModel = item.getUser();
            if (item.getMessageType() == FakeMessage.MessageType.Join) {
                tvMsg.setText(formatMessage(userModel, item.getMsg()));
                tvMsg.setTextColor(
                        ContextCompat.getColor(tvMsg.getContext(), R.color.msg_user_other));
            } else if (item.getMessageType() == FakeMessage.MessageType.Msg) {
                String msg = item.getMsg();
                if (ObjectsCompat.equals(mine, userModel)
                        || ObjectsCompat.equals(owner, userModel)) {
                    tvMsg.setTextColor(
                            ContextCompat.getColor(tvMsg.getContext(), R.color.msg_user_mime));
                    tvMsg.setText(formatMessage(userModel, msg));
                } else {
                    String name = userModel.getNickName();
                    if (TextUtils.isEmpty(name)) {
                        name = String.valueOf(userModel.getUid());
                    }

                    SpannableString ss = new SpannableString(name + " " + msg);
                    ss.setSpan(new ForegroundColorSpan(ContextCompat.getColor(tvMsg.getContext(),
                            R.color.msg_user_mime)), 0, name.length(),
                            Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
                    ss.setSpan(new ForegroundColorSpan(ContextCompat.getColor(tvMsg.getContext(),
                            R.color.msg_user_other)), name.length() + 1,
                            name.length() + 1 + msg.length(),
                            Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
                    tvMsg.setText(ss);
                }
            } else if (item.getMessageType() == FakeMessage.MessageType.Notice) {
                if (userModel == null) {
                    tvMsg.setText(item.getMsg());
                } else {
                    tvMsg.setText(formatMessage(userModel, item.getMsg()));
                }
                tvMsg.setTextColor(
                        ContextCompat.getColor(tvMsg.getContext(), R.color.msg_user_mime));
            } else if (item.getMessageType() == FakeMessage.MessageType.Top) {
                tvMsg.setText(item.getMsg());
                tvMsg.setTextColor(
                        ContextCompat.getColor(tvMsg.getContext(), R.color.msg_user_other));
            }
        }

        private String formatMessage(User user, String msg) {
            if (ObjectsCompat.equals(mine, user)) {
                return mContext.getString(R.string.msg_text_mine, msg);
            } else {
                if (TextUtils.isEmpty(user.getNickName())) {
                    return String.format("%s %s", String.valueOf(user.getUid()), msg);
                } else {
                    return String.format("%s %s", user.getNickName(), msg);
                }
            }
        }
    }
}
