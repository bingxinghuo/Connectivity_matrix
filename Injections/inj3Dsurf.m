%% coronal view
injmaxcor1=uint8(zeros(H,W,C));
for c=1:C
    for h=1:H
        for w=1:W
            injmaxcor1(h,w,c)=max(injstack1(h,w,c,:));
        end
    end
end
% sagittal view
injmaxsag1=uint8(zeros(H,N1,C));
for c=1:C
    for h=1:H
        for n=1:N1
            injmaxsag1(h,n,c)=max(injstack1(h,:,c,n));
        end
    end
end
% transverse view
injmaxtrans1=uint8(zeros(W,N1,C));
for c=1:C
    for w=1:W
        for n=1:N1
            injmaxtrans1(w,n,c)=max(injstack1(:,w,c,n));
        end
    end
end