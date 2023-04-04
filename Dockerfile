FROM basic-ulfius

COPY test.bas .

RUN fbc test.bas -l ulfius -l orcania -l yder -l jansson

CMD ./test
