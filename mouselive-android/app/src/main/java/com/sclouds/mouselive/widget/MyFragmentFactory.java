package com.sclouds.mouselive.widget;

import com.sclouds.mouselive.views.KTVChatFragment;
import com.sclouds.mouselive.views.KTVChatingFragment;
import com.sclouds.mouselive.views.KTVMembersFragment;

import androidx.annotation.NonNull;
import androidx.core.util.ObjectsCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentFactory;

/**
 * @author Aslan chenhengfei@yy.com
 * @date 2020/7/7
 */
public class MyFragmentFactory extends FragmentFactory {
    @NonNull
    @Override
    public Fragment instantiate(@NonNull ClassLoader classLoader, @NonNull String className) {
        if (ObjectsCompat.equals(KTVChatFragment.class.getSimpleName(), className)) {
            return new KTVChatFragment();
        } else if (ObjectsCompat.equals(KTVMembersFragment.class.getSimpleName(), className)) {
            return new KTVMembersFragment();
        } else if (ObjectsCompat.equals(KTVChatingFragment.class.getSimpleName(), className)) {
            return new KTVChatingFragment();
        }
        return super.instantiate(classLoader, className);
    }
}
