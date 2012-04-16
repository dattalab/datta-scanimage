function same = eq(scope1, scope2)

same = 0;
if strcmpi(class(scope2), 'scopeobject')
    same = (scope1.ptr == scope2.ptr);
end

return;